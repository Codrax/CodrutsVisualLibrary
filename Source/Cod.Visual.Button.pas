﻿unit Cod.Visual.Button;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Controls,
  Messaging,
  Winapi.Windows,
  Vcl.Forms,
  Cod.Visual.CPSharedLib,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  Vcl.Styles,
  Vcl.Themes,
  System.UITypes,
  Cod.VarHelpers,
  System.Win.Registry,
  Cod.Components,
  Cod.ColorUtils,
  Cod.Graphics;

type
  CButton = class;

  CPosition = (cpLeft, cpRight, cpTop, cpBottom);
  CButtonState = (mbsLeave, mbsEnter, mbsDown);
  CButtonAnimateEngine = (cbneComponent, cbneAtDraw);
  //CButtonIconAlign = (cbiaLeft, cbiaRight, cbiaTop, cbiaBottom);
  CButtonIcon = (cicNone, cicSegoeFluent, cicYes, cicNo, cicTrueYes, cicNoAllow,
                 cicQuestion, cicWarning, cicStart, cicNext, cicBack, cicUp,
                 cicDown, cicArrow, cicEnter, cicRetry, cicDownload, cicUpload,
                 cicSearch, cicSearchL);
  CButtonStateChange = procedure(Sender: CButton; State: CButtonState) of object;
  CButtonPreset = (cbprCustom, cbprFluent, cbprFluentFlat, cbprFluentRound,
                   cbprMetro, cbprMetroLink, cbprMetroSimple, cbprMetroFade,
                   cbprFluentGray, cbprClassic, cbprNewClassic,
                   cbprGlobalApplyColor, cbprWin32, cbprAeroLink, cbprLink);

  CButtonPresets = class(TMPersistent)
    public

    private
      FrColor : TColor;
      FpKind : CButtonPreset;
      FAutoPen,
      FApplyOnce, FIgnGbSync: boolean;
      function Paint : Boolean;
    published
      property Color : TColor read FrColor write FrColor stored Paint;
      property Kind : CButtonPreset read FpKind write FpKind stored Paint;
      property PenColorAuto : boolean read FAutoPen write FAutoPen stored Paint;
      property ApplyOnce : boolean read FApplyOnce write FApplyOnce stored Paint;
      property IgnoreGlobalSync : boolean read FIgnGbSync write FIgnGbSync stored Paint;
  end;

  CButtonUnderLine = class(TMPersistent)
    private
      FUnderThick: integer;
      FUnderLn, FUnderLnRound: boolean;
      procedure SetUline(const Value: boolean);
      procedure SetULRound(const Value: boolean);
      procedure SetUlThick(const Value: integer);
    published
      property Enable : boolean read FUnderLn write SetUline;
      property UnderLineRound : boolean read FUnderLnRound write SetULRound;
      property UnderLineThicknes : integer read FUnderThick write SetUlThick;
  end;

  CButtonColors = class(TMPersistent)
    private
      FEnter, FLeave, FDown: TColor;
      FLine: TColor;
      function Paint : Boolean;
    published
      property Enter : TColor read FEnter write FEnter stored Paint;
      property Leave : TColor read FLeave write FLeave stored Paint;
      property Down : TColor read FDown write FDown stored Paint;
      property BLine : TColor read FLine write FLine stored Paint;
  end;

  CButtonGradientSet = class(TMPersistent)
    private
      FEnter, FLeave, FDown: TColor;
      FEnabled: boolean;
      function Paint : Boolean;
    published
      property Enabled : boolean read FEnabled write FEnabled stored Paint;
      property Enter : TColor read FEnter write FEnter stored Paint;
      property Leave : TColor read FLeave write FLeave stored Paint;
      property Down : TColor read FDown write FDown stored Paint;
  end;

  CButtonFontAutoSize = class(TMPersistent)
    private
      FEnabled: boolean;
      FMax, FMin: integer;
      function Paint : Boolean;
    published
      property Enabled : boolean read FEnabled write FEnabled stored Paint;
      property Max : integer read FMax write FMax stored Paint;
      property Min : integer read FMin write FMin stored Paint;
  end;

  CButtonAnimations = class(TMPersistent)
    private
      FPAn, FFadeAnimation: boolean;
      FAnimdelay, FAnimshq, TimeProg, FFadeSpeed: integer;
      FAnimateEngine: CButtonAnimateEngine;
    published
      property PressAnimation : boolean read FPAn write FPAn;
      property PADelay : integer read FAnimdelay write FAnimdelay;
      property PAShrinkAmount : integer read FAnimshq write FAnimshq;
      property PAAnimateEngine : CButtonAnimateEngine read FAnimateEngine write FAnimateEngine;

      property FadeAnimation: boolean read FFadeAnimation write FFadeAnimation;
      property FASpeed: integer read FFadeSpeed write FFadeSpeed;
  end;

  CButtonPen = class(TMPersistent)
    private
      FColor : TColor;
      FWidth : integer;
      FEnablePenAlt,
      FSyncBgColor: boolean;
      FCPenDown: TColor;
      FCPenHover: TColor;
      exceptpreset: boolean;
      function Paint : Boolean;
    published
      property Color : TColor read FColor write FColor stored Paint;
      property Width : integer read FWidth write FWidth stored Paint;
      property EnableAlternativeColors : boolean read FEnablePenAlt write FEnablePenAlt stored Paint;
      property FormSyncedColor : boolean read FSyncBgColor write FSyncBgColor;
      property AltHoverColor : TColor read FCPenHover write FCPenHover stored Paint;
      property AltPressColor : TColor read FCPenDown write FCPenDown stored Paint;
      property GlobalPresetExcept: boolean read exceptpreset write exceptpreset;
  end;

  CButton = class(TCustomControl)
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  private
    FAuthor, FSite, FVersion: string;
    FonStateChange: CButtonStateChange;
    FPreset: CButtonPresets;
    FColors: CButtonColors;
    FIsDestroy: boolean;
    FPen: CButtonPen;
    FBitmap: TPicture;
    FMBTColor: TColor;
    FTextColors: CButtonColors;
    FAnimations: CButtonAnimations;
    FTransparent,
    FCustTColor,
    FFlatBT,
    FFlatComplete,
    FEnableCaption,
    FCancel,
    FAutoExtendImage,
    FDefault: Boolean;
    w, h, fs: integer;
    FGradientSet: CButtonGradientSet;
    FFontAutoSize: CButtonFontAutoSize;
    FUnderLine: CButtonUnderLine;
    FCIcon: CButtonIcon;
    FModalResult: TModalResult;
    FRoundAmount: integer;
    FText: string;
    FSubText: string;
    FEnableSubText: boolean;
    FState, FPreviousState: CButtonState;
    FFont: TFont;
    FSubTextFont: TFont;
    FAlign: TAlignment;
    FControlStyle: TControlStyle;
    ShX, ShY: integer;
    FImageLayout: CPosition;
    FTxtWSpace: integer;
    FSegoeIcon: string;
    FSegoeMetro: boolean;
    FAccent: CAccentColor;
    //FTrueTransparency: boolean;

    FadeAnim: TTimer;

    function FadeBrushColor(from, towhich: CButtonState; progress: integer; isflat: boolean = false; gradientcolor: boolean = false): TColor;
    function FadeFontColor(from, towhich: CButtonState; progress: integer): TColor;

    procedure StTimer;
    procedure FTimerAct(Sender: TObject);
    procedure SetBitmap(Value: TPicture);
    procedure SetText(cOnst Value: string);
    procedure SetState(const Value: CButtOnState);
    procedure SetFont(const Value: TFont);
    procedure SetTransparent(const Value: boolean);
    procedure SetRoundVal(const Value: integer);
    procedure SetFlatnes(const Value: boolean);
    procedure ApplyPreset(const Value: CButtonPresets);
    procedure SetIcon(const Value: CButtonIcon);
    procedure SetFMBTColor(const Value: TColor);
    function CheckForGlobalSync: boolean;
    procedure SetFCustColor(const Value: boolean);
    function ClrGray(clr: TColor): TColor;
    procedure SetAlign(const Value: TAlignment);
    procedure SetDefault(const Value: boolean);
    procedure SetCancel(const Value: boolean);
    procedure SetFlatComplete(const Value: boolean);
    procedure SetShowCaption(const Value: boolean);
    procedure SetFontAutoSize(const Value: CButtonFontAutoSize);
    procedure SetGradient(const Value: CButtonGradientSet);
    procedure SetImageLayout(const Value: CPosition);
    procedure SetSegoeIcon(const Value: string);
    procedure SetMetroIcon(const Value: boolean);
    procedure SetAccentColor(const Value: CAccentColor);
    procedure SetSubFont(const Value: TFont);
    procedure SetSubText(const Value: string);
    procedure SetEnableSubText(const Value: boolean);
    procedure SetTextWall(const Value: integer);
    procedure SetAutoExtendImage(const Value: boolean);

    { Private declarations }
  protected
    procedure Paint; override;

    procedure Animation(undo: boolean);
    procedure CMMouseEnter(var Message : TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
    procedure MouseDown(Button : TMouseButton; Shift: TShiftState; X, Y : integer); override;
    procedure MouseUp(Button : TMouseButton; Shift: TShiftState; X, Y : integer); override;
    procedure KeyPress(var Key: Char); override;
    procedure Click; override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure SetEnabled(Value: Boolean); override;
    procedure ApplyAccentColor;

  published
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
    property OnEnter;
    property OnExit;
    property PopupMenu;
    property ModalResult: TModalResult read FModalResult write FModalResult default 0;
    property OnKeyPress;
    property OnKeyDown;
    property OnKeyUp;
    property OnClick;
    property OnStateChange : CButtOnStateChange read FOnStateChange write FOnStateChange;

    property Allignment: TAlignment read FAlign write SetAlign default taCenter;

    property Default: boolean read FDefault write SetDefault default false;
    property Cancel: boolean read FCancel write SetCancel default false;

    property Action;
    property ShowHint;
    property TabStop default True;
    property TabOrder;
    property Align;
    property Anchors;
    property Constraints;
    property Cursor;
    property Visible;
    property Enabled;
    property DoubleBuffered;

    property Color;
    property ParentColor;

    property BSegoeMetro: boolean read FSegoeMetro write SetMetroIcon default false;
    property BSegoeIcon: string read FSegoeIcon write SetSegoeIcon;
    property BImageLayout: CPosition Read FImageLayout write SetImageLayout default cpLeft;
    property BmpTransparentColor: TColor Read FMBTColor Write SetFMBTColor default clWhite;
    property BPicture: TPicture Read FBitmap Write SetBitmap;
    property ButtonIcon: CButtonIcon read FCIcon write SetIcon default cicNone;
    property BmpCustomTrColor: boolean read FCustTColor write SetFCustColor default false;

    property ShowCaption: boolean read FEnableCaption write SetShowCaption default true;
    property UseAccentColor: CAccentColor read FAccent write SetAccentColor default CAccentColor.AccentAdjust;

    property GradientOptions : CButtonGradientSet read FGradientSet write SetGradient;
    property ControlStyle : TControlStyle read FControlStyle write FControlStyle;

    property Font : TFont read FFont write SetFont stored True;
    property SubTextFont : TFont read FSubTextFont write SetSubFont stored True;
    property FontAutoSize : CButtonFontAutoSize read FFontAutoSize write SetFontAutoSize;
    property Text : string read FText write SetText;
    property SubText : string read FSubText write SetSubText;
    property SubTextEnabled : boolean read FEnableSubText write SetEnableSubText default false;
    property TextWallSpacing : integer read FTxtWSpace write SetTextWall default 10;
    property AutoExtendImage: boolean read FAutoExtendImage write SetAutoExtendImage;

    property RoundTransparent : boolean read FTransparent write SetTransparent default true;
    property RoundAmount : integer read FRoundAmount write SetRoundVal default 10;
    property State : CButtonState read FState write SetState;
    property FlatButton : boolean read FFlatBT write SetFlatnes default false;
    property FlatComplete : boolean read FFlatComplete write SetFlatComplete default false;
    property Colors : CButtonColors read FColors write FColors;
    property Preset : CButtonPresets read FPreset write ApplyPreset;
    property UnderLine: CButtonUnderLine read FUnderLine write FUnderLine;
    property TextColors : CButtOnColors read FTextColors write FTextColors;
    property Pen : CButtonPen read FPen write FPen;
    property Animations: CButtonAnimations read FAnimations write FAnimations;

    property &&&Author: string Read FAuthor;
    property &&&Site: string Read FSite;
    property &&&Version: string Read FVersion;
  public
    procedure SetFocus(); override;
    procedure Invalidate; override;
  end;

const
  defaultunderln = 6;
  AnimSizeDvz = 50;

  FONT_SEGOE_FLUENT = 'Segoe Fluent Icons';
  FONT_SEGOE_METRO = 'Segoe MDL2 Assets';

var
  GlobalSync: boolean = false;
  gspreset: CButtonPreset = cbprFluent;
  gspresetcolor: TColor = clBlue;

implementation

{ CButtonColors }
functiOn CButtonColors.Paint: Boolean;
begin
  if Self.Owner is CButton then begin
    CButton(Self.Owner).Paint;
    Result := True;
  end else Result := False;
end;

{ CButtonPen }
functiOn CButtOnPen.Paint: Boolean;
begin
  if Self.Owner is CButton then begin
    CButtOn(Self.Owner).Paint;
    Result := True;
  end else Result := False;
end;

{ CButton }

procedure CButton.Animation(undo: boolean);
var
  i, x, y: integer;
begin
  if not FAnimations.FPAn then Exit;

  if FAnimations.PAAnimateEngine = cbneAtDraw then begin

    for i := 1 to FAnimations.FAnimshq do begin
      Sleep(FAnimations.FAnimdelay);

      x := round(width / AnimSizeDvz);
      Y := round(height / AnimSizeDvz);

      if x < 1 then x := 1;
      if y < 1 then y := 1;
    

      if undo then begin
        dec(shX, x);
        dec(shY, y);
      end else begin
        inc(shX, x);
        inc(shY, y);
      end;

      FTimerAct(nil);

      Paint;
    end;
  end else
  begin
      if undo then begin
      w := w * -1;
      h := h * -1;
      fs := fs * -1;
    end else begin
      w := trunc(Width / 40);
      h := trunc(Height / 40);
      fs := trunc(FFont.Size / 40);
      if fs = 0 then fs := 1;
      if w = 0 then w := 1;
      if h = 0 then h := 1;
    end;
    //Experiment
    for i := 1 to FAnimations.FAnimshq do begin
      Sleep(FAnimations.FAnimdelay);
      FFont.Size := FFont.Size -fs;
      Width := Width + (w * -1);
      Height := Height + (h * -1);
      Left := Left + round(w / 2);
      Top := Top + round(h / 2);

      Paint;
    end;
  end;
end;

function CButton.ClrGray(clr: TColor): TColor;
var
  RBGval: longint;
  R, G, B: integer;
begin
  RBGval := ColorToRGB(clr);
  R := GetRValue(RBGval);
  G := GetGValue(RBGval);
  B := GetBValue(RBGval);

  R:= (R+G+B) div 3;
  G:= R; B:=R;

  Result := RGB(r,g,b);
end;

procedure CButton.ApplyAccentColor;
var
  AccColor: TColor;
begin
  if FAccent = CAccentColor.None then
    Exit;

  AccColor := GetAccentColor(FAccent);

  FColors.FLeave := ChangeColorSat(AccColor, 15);
  FColors.FEnter := ChangeColorSat(FColors.FLeave, 40);
  FColors.FDown := ChangeColorSat(FColors.FLeave, -40);
  FColors.FLine := ChangeColorSat(FColors.FLeave, -40);
end;

procedure CButton.ApplyPreset(const Value: CButtonPresets);
begin
  FPreset := Value;
  if (Preset.Kind = CButtonPreset.cbprCustom) or ((FPen.exceptpreset) and (FPReset.FpKind <> CButtonPreset.cbprGlobalApplyColor)) then Exit;

  if FPreset.FpKind = CButtonPreset.cbprGlobalApplyColor then
    FPreset.FrColor := gspresetcolor;

    if FAccent = CAccentColor.None then
    if FPreset.Color <> clWhite then begin
      FTextColors.FEnter := clWhite;
      FTextColors.FDown := ChangeColorSat(FTextColors.Leave,-5);
      FTextColors.FLeave := clWhite;
      if FPreset.FAutoPen then FPen.Color := clWhite;
      FColors.FLeave := FPreset.Color;
      FColors.Enter := ChangeColorSat(FPreset.Color,40);
      FColors.Down := ChangeColorSat(FPreset.Color,-40);
      FColors.FLine := ChangeColorSat(FPreset.Color,-40);
    end else begin
      FTextColors.FEnter := clBlack;
      FTextColors.FDown := clWhite;
      FTextColors.FLeave := clBlack;
      if FPreset.FAutoPen then FPen.Color := clBlack;
      FColors.FLeave := clWhite;
      FColors.Enter := ChangeColorSat(clWhite,-25);
      FColors.Down := clBlack;
      FColors.FLine := clBlack;
    end;


  //For All
  FEnableCaption := true;
  FFlatComplete := false;
  ParentColor := false;
  FPen.EnableAlternativeColors := false;

  //Individual
  case FPreset.Kind of
    CButtonPreset.cbprFluent: begin
      FEnableSubText := false;
      ParentColor := true;
      FAnimations.FAnimateEngine := cbneAtDraw;
      FPen.FSyncBgColor := true;
      FPen.FEnablePenAlt := false;
      FRoundAmount := 10;
      FFont.Size := 12;
      FFont.Style := [];
      FFont.Name := 'Segoe UI Semibold';
      FPen.Width := 0;
      FFlatBT := false;
      FUnderLine.FUnderLn := true;
      FUnderLine.FUnderLnRound := true;
      FUnderLine.FUnderThick := defaultunderln;
      FAnimations.FPan := false;
      FTransparent := true;
      FAnimations.FFadeAnimation := true;
      FAnimations.FASpeed := 10;
    end;
    CButtonPreset.cbprFluentFlat: begin
      FEnableSubText := false;
      ParentColor := true;
      FAnimations.FAnimateEngine := cbneAtDraw;
      FPen.FSyncBgColor := true;
      FPen.FEnablePenAlt := false;
      FRoundAmount := 10;
      FFont.Size := 12;
      FFont.Style := [];
      FFont.Name := 'Segoe UI Semibold';
      FPen.Width := 0;
      FFlatBT := false;
      FUnderLine.FUnderLn := true;
      FUnderLine.FUnderLnRound := true;
      FUnderLine.FUnderThick := defaultunderln;
      FAnimations.FPan := false;
      FTransparent := true;
      FAnimations.FFadeAnimation := true;
      FAnimations.FASpeed := 10;
      FFlatBT := true;
    end;
    CButtonPreset.cbprFluentRound: begin
      FEnableSubText := false;
      ParentColor := true;
      FAnimations.FAnimateEngine := cbneAtDraw;
      FPen.FSyncBgColor := true;
      FPen.FEnablePenAlt := false;
      FRoundAmount := 25;
      FFont.Size := 12;
      FFont.Style := [];
      FFont.Name := 'Segoe UI Semibold';
      FPen.Width := 0;
      FFlatBT := false;
      FUnderLine.FUnderLn := true;
      FUnderLine.FUnderThick := defaultunderln;
      FUnderLine.FUnderLnRound := true;
      FAnimations.FPAn := false;
      FTransparent := true;
      FAnimations.FFadeAnimation := true;
      FAnimations.FASpeed := 10;
    end;
    CButtonPreset.cbprMetroFade: begin
      FEnableSubText := false;
      FAnimations.FAnimateEngine := cbneAtDraw;
      FPen.FSyncBgColor := false;
      FPen.FEnablePenAlt := false;
      FRoundAmount := 0;
      FFont.Size := 12;
      FFont.Style := [];
      FFont.Name := 'Segoe UI Semibold';
      FPen.Width := 2;
      FFlatBT := false;
      FColors.FLine := clWhite;
      FUnderLine.FUnderLn := false;
      FAnimations.FPAn := false;
      FTransparent := false;
      FAnimations.FFadeAnimation := true;
    end;
    CButtonPreset.cbprMetroSimple: begin
      FEnableSubText := false;
      FAnimations.FAnimateEngine := cbneAtDraw;
      FPen.FSyncBgColor := false;
      FPen.FEnablePenAlt := false;
      FRoundAmount := 0;
      FFont.Size := 12;
      FFont.Style := [];
      FFont.Name := 'Segoe UI Semibold';
      FPen.Width := 0;
      FFlatBT := false;
      FColors.FLine := clWhite;
        FColors.FDown := clBlack;
        FTextColors.FDown := clWhite;
      FUnderLine.FUnderLn := false;
      FAnimations.FPAn := false;
      FTransparent := false;
      FAnimations.FFadeAnimation := false;
    end;
    CButtonPreset.cbprMetro: begin
      FEnableSubText := false;
      FAnimations.FAnimateEngine := cbneAtDraw;
      FPen.FSyncBgColor := false;
      FPen.FEnablePenAlt := false;
      FRoundAmount := 0;
      FFont.Size := 12;
      FFont.Style := [];
      FFont.Name := 'Segoe UI Semibold';
      FPen.Width := 2;
      FFlatBT := false;
      FColors.FLine := clWhite;
      if Pen.Color = clWhite then begin
        FColors.FDown := clWhite;
        FTextColors.FDown := clBlack;
      end else begin
        FColors.FDown := clBlack;
        FTextColors.FDown := clWhite;
      end;
      FUnderLine.FUnderLn := false;
      FAnimations.FPAn := false;
      FTransparent := false;
      FAnimations.FFadeAnimation := false;
    end;
    CButtonPreset.cbprMetroLink: begin
      FEnableSubText := true;
      FAnimations.FAnimateEngine := cbneAtDraw;
      FPen.FSyncBgColor := false;
      FPen.FEnablePenAlt := false;
      FRoundAmount := 0;
      FFont.Size := 12;
      FFont.Style := [fsBold];
      FFont.Name := 'Segoe UI Semibold';
      FPen.Width := 2;
      FFlatBT := false;
      FColors.FLine := clWhite;
      if Pen.Color = clWhite then begin
        FColors.FDown := clWhite;
        FTextColors.FDown := clBlack;
      end else begin
        FColors.FDown := clBlack;
        FTextColors.FDown := clWhite;
      end;
      FUnderLine.FUnderLn := false;
      FAnimations.FPAn := false;
      FTransparent := false;
      FAnimations.FFadeAnimation := false;
    end;
    CButtonPreset.cbprFluentGray: begin
      FEnableSubText := false;
      FAnimations.FAnimateEngine := cbneComponent;
      FPen.FSyncBgColor := false;
      FPen.FEnablePenAlt := true;
      FRoundAmount := 0;
      FFont.Size := 10;
      FFont.Style := [];
      FFont.Name := 'Segoe UI';
      FPen.Width := 3;
      FFlatBT := false;
      FUnderLine.FUnderLn := false;
      FAnimations.FPAn := true;
      FAnimations.FAnimshq := 2;
      FAnimations.FAnimdelay := 2;
      FTransparent := false;
      //Always Colors
      FPen.Color := $004E4E4E;
      FPen.AltHoverColor := $00878787;
      FPen.AltPressColor := $00878787;
      FColors.FDown := $00878787;
      FColors.Leave := $004E4E4E;
      FColors.Enter := $004E4E4E;
      FTextColors.FLeave := clWhite;
      FTextColors.FDown := clWhite;
      FTextColors.FEnter := clWhite;
      FAnimations.FFadeAnimation := true;
      FAnimations.FASpeed := 10;
    end;
    CButtonPreset.cbprClassic: begin
      FEnableSubText := false;
      FAnimations.FAnimateEngine := cbneAtDraw;
      FPen.FSyncBgColor := false;
      FPen.FEnablePenAlt := false;
      FRoundAmount := 0;
      FFont.Size := 8;
      FFont.Style := [];
      FFont.Name := 'Tahoma';
      FPen.Width := 1;
      FFlatBT := false;
      FUnderLine.FUnderLn := false;
      FAnimations.FPAn := false;
      FTransparent := false;
      //Always Colors
      FColors.FDown := clBtnShadow;
      FColors.Leave := clBtnFace;
      FColors.Enter := clWhite;
      FTextColors.FLeave := clWindowText;
      FTextColors.FDown := clWindowText;
      FTextColors.FEnter := clWindowText;
      FPen.Color := clGray;
      FAnimations.FFadeAnimation := true;
      FAnimations.FASpeed := 10;
    end;
    CButtonPreset.cbprNewClassic: begin
      FEnableSubText := false;
      FAnimations.FAnimateEngine := cbneAtDraw;
      FPen.FSyncBgColor := false;
      FPen.FEnablePenAlt := false;
      FRoundAmount := 0;
      FFont.Size := 8;
      FFont.Style := [];
      FFont.Name := 'Tahoma';
      FPen.Width := 1;
      FFlatBT := false;
      FUnderLine.FUnderLn := false;
      FAnimations.FPAn := false;
      FTransparent := false;
      //Always Colors
      FColors.FDown := clBtnShadow;
      FColors.Leave := clBtnFace;
      FColors.Enter := clWhite;
      FTextColors.FLeave := clWindowText;
      FTextColors.FDown := clWindowText;
      FTextColors.FEnter := clWindowText;
      FPen.Color := clBlue;
      FAnimations.FFadeAnimation := true;
      FAnimations.FASpeed := 10;
    end;
    CButtonPreset.cbprWin32: begin
      FEnableSubText := false;
      FAnimations.FAnimateEngine := cbneAtDraw;
      FPen.FSyncBgColor := false;
      FPen.FEnablePenAlt := true;
      FRoundAmount := 0;
      FFont.Size := 8;
      FFont.Style := [];
      FFont.Name := 'Tahoma';
      FPen.Width := 1;
      FFlatBT := false;
      FUnderLine.FUnderLn := false;
      FAnimations.FPAn := false;
      FTransparent := false;
      //Always Colors
      FColors.FDown := $00F7E4CC;
      FColors.Leave := $00E1E1E1;
      FColors.Enter := $00FBF1E5;
      FTextColors.FLeave := clWindowText;
      FTextColors.FDown := clWindowText;
      FTextColors.FEnter := clWindowText;
      FPen.Color := $00ADADAD;
      FPen.AltHoverColor := $00D77800;
      FPen.AltPressColor := $00995400;
      FAnimations.FFadeAnimation := true;
      FAnimations.FASpeed := 10;
    end;
    CButtonPreset.cbprAeroLink: begin
      FCIcon := cicArrow;
      FEnableSubText := true;
      FAnimations.FAnimateEngine := cbneAtDraw;
      FSubTextFont.Size := 8;
      FPen.FSyncBgColor := false;
      FPen.FEnablePenAlt := true;
      FRoundAmount := 0;
      FPen.Width := 0;
      FFlatBT := false;
      FUnderLine.FUnderLn := false;
      FAnimations.FPAn := false;
      FTransparent := false;
      FPen.Width := 1;
      FPen.EnableAlternativeColors := true;
      //Always Colors
      FColors.FDown := 14211288;
      FColors.FLeave := 15790320;
      FColors.FEnter := 15790320;
      FTextColors.FLeave := 14322471;
      FTextColors.FDown := 7544838;
      FTextColors.FEnter := 15026695;
      FPen.FCPenHover := 14211288;
      FPen.Color := $00E1E1E1;
      FPen.FCPenDown := 12632256;
      FAnimations.FFadeAnimation := true;
      FAnimations.FASpeed := 10;
    end;
    CButtonPreset.cbprLink: begin
      FCIcon := cicArrow;
      FEnableSubText := true;
      FAnimations.FAnimateEngine := cbneAtDraw;
      FPen.FSyncBgColor := false;
      FPen.FEnablePenAlt := true;
      FRoundAmount := 0;
      FPen.Width := 0;
      FFlatBT := false;
      FUnderLine.FUnderLn := false;
      FAnimations.FPAn := false;
      FTransparent := false;
      FPen.Width := 3;
      FPen.EnableAlternativeColors := true;
      //Always Colors
      FColors.FDown := $00F7E4CC;
      FColors.FLeave := $00E1E1E1;
      FColors.FEnter := $00FBF1E5;
      FTextColors.FLeave := 14322471;
      FTextColors.FDown := 14322471;
      FTextColors.FEnter := 14322471;
      FPen.Color := $00E1E1E1;
      FPen.FCPenHover := 15389364;
      FPen.FCPenDown := $00F7E4CC;
      FAnimations.FFadeAnimation := true;
      FAnimations.FASpeed := 10;
    end;
  end;

  if (FPreset.FpKind <> CButtonPreset.cbprCustom) and FPreset.FApplyOnce then
    Preset.FpKind := CButtonPreset.cbprCustom;
end;

function CButton.CheckForGlobalSync: boolean;
begin
  Result := false;

  // Check Global Sync
  if not FPreset.FIgnGbSync then
    if not ((csReading in ComponentState) or (csLoading in ComponentState)) then
      if GlobalSync then
        begin
          FPreset.FpKind := gspreset;
          FPreset.FrColor := gspresetcolor;
          Result := true;
        end;
end;

procedure CButton.Click;
var
  Form: TCustomForm;
begin
  inherited;

  Form := GetParentForm(Self);
  if Form <> nil then
    Form.ModalResult := ModalResult;
end;

procedure CButton.CMDialogKey(var Message: TCMDialogKey);
begin
  with Message do
    if  (((CharCode = VK_RETURN) and FDefault) or
      ((CharCode = VK_ESCAPE) and FCancel)) and
      (KeyDataToShiftState(Message.KeyData) = []) and CanFocus then
    begin
      Click;
      Result := 1;
    end else
      inherited;
end;

procedure CButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  SetState(mbsEnter);
  if Assigned(FOnStateChange) then FOnStateChange(Self, FState);
end;

procedure CButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  SetState(mbsLeave);
  if Assigned(FOnStateChange) then FOnStateChange(Self, FState);
end;

constructor CButton.Create(AOwner: TComponent);
begin
  inherited;
  FAuthor                       := 'Petculescu Codrut';
  FSite                         := 'https://www.codrutsoftware.cf';
  FVersion                      := '1.3';

  //interceptmouse := true;

  FAlign := taCenter;

  TabStop := true;

  FEnableCaption := true;

  FGradientSet := CButtonGradientSet.Create(Self);
  with FGradientSet do begin
    FEnabled := false;
    FDown := clMaroon;
    FEnter := clFuchsia;
    FLeave := clRed;
  end;

  FFontAutoSize := CButtonFontAutoSize.Create(Self);
  with FFontAutoSize do begin
    FEnabled := false;
    FMax := -1;
    FMin := -1;
  end;

  FColors := CButtOnColors.Create(Self);
  with FColors do begin
    Enter := $00D7821A;
    Leave := $00C57517;
    Down := $008E5611;
    BLine := $008E5611;;
  end;

  FadeAnim := TTimer.Create(Self);
  with FadeAnim do begin
    Interval := 1;
    Enabled := false;
    FadeAnim.OnTimer := FTimerAct;
  end;

  FAnimations := CButtonAnimations.Create;
  with FAnimations do begin
    FAnimations.FPAn := false;
    PAAnimateEngine := cbneAtDraw;
    FAnimdelay := 2;
    FFadeSpeed := 10;
    FAnimshq := 6;
  end;
  
  FTextColors := CButtonColors.Create(Self);
  with FTextColors do begin
    Enter := clWhite;
    Leave := clWhite;
    Down := clWhite;
  end;

  FUnderLine := CButtonUnderLine.Create(Self);
  with FUnderLine do begin
    FUnderLnRound := true;
    FUnderThick := defaultunderln;
    FUnderLn := true;
  end;

  FPreset := CButtonPresets.Create(Self);
  with FPreset do begin
    Kind := CButtonPreset.cbprCustom;
    Color := clBlue;
    FAutoPen := true;
    FApplyOnce := false;
    FIgnGbSync := false;
  end;

  FPen := CButtonPen.Create(self);
  With FPen do begin
    Width := 2;
    Color := clWindow;
    FPen.FEnablePenAlt := false;
    FSyncBgColor := false;  //set to FALSE because changed how parent color it got. Now using Self.ParentColor
    exceptpreset := false;
  end;

  FFont := TFont.Create;
  with FFont do begin
    Name := 'Segoe UI Semibold';
    Size := 12;
    Color := $00D7821A;
  end;

  FSubText := 'Hello World!';
  FEnableSubText := false;

  FSubTextFont := TFont.Create;
  with FSubTextFont do begin
    Name := 'Segoe UI';
    Size := 10;
    Color := $00D7821A;
  end;

  FTxtWSpace := 10;

  FCIcon := cicNone;

  FBitmap := TPicture.Create;

  FMBTColor := clWhite;

  FAccent := CAccentColor.AccentAdjust;
  ApplyAccentColor;

  Width := 110;
  Height := 40;

  FText := 'Click me';
  FState := mbsLeave;

  FCustTColor := false;
  FSegoeMetro := false;
  FSegoeIcon := '';

  FImageLayout := cpLeft;

  FAnimations.FFadeAnimation := true;

  Pen.Width := 0;
  FTransparent := true;
  FRoundAmount := 10;
end;

destructor CButton.Destroy;
begin
  FIsDestroy := true;
  FreeAndNil( FPen );
  FreeAndNil( FColors );
  FBitmap.Free;
  FBitmap := nil;
  FreeAndNil( FAnimations );
  FadeAnim.Enabled := false;
  FreeAndNil( FadeAnim );
  FreeAndNil( FUnderLine );
  FreeAndNil( FTextColors );
  FreeAndNil( FFont );
  FreeAndNil( FPreset );
  inherited;
end;

procedure CButton.DoEnter;
begin
  inherited;
  SetState(mbsEnter);
end;

procedure CButton.DoExit;
begin
  inherited;
  SetState(mbsLeave);

  if FDefault then
    //Self.SetFocus;
end;

function CButton.FadeBrushColor(from, towhich: CButtonState;
  progress: integer; isflat: boolean; gradientcolor: boolean): TColor;
var
  c1, c2: TColor;
  flatmt: integer;
begin
  c1 := clWhite;
  c2 := clWhite;

  if FFlatComplete then
    flatmt := 0
  else
    flatmt := 1;

  if NOT gradientcolor then
  begin
    case from of
      mbsDown: if isflat then c1 := ChangeColorSat(FPen.Color,-15 * flatmt) else
        c1 := FColors.Down;
      mbsLeave: if isflat then c1 := ChangeColorSat(FPen.Color,-3 * flatmt) else
         c1 := FColors.Leave;
      mbsEnter: if isflat then c1 := ChangeColorSat(FPen.Color,-5 * flatmt) else
         c1 := FColors.Enter;
    end;
    case towhich of
      mbsDown: if isflat then c2 := ChangeColorSat(FPen.Color,-15 * flatmt) else
         c2 := FColors.Down;
      mbsLeave: if isflat then c2 := ChangeColorSat(FPen.Color,-3 * flatmt) else
         c2 := FColors.Leave;
      mbsEnter: if isflat then c2 := ChangeColorSat(FPen.Color,-5 * flatmt) else
         c2 := FColors.Enter;
    end;
  end
  else begin
    case from of
      mbsDown: c1 := FGradientSet.Down;
      mbsLeave: c1 := FGradientSet.Leave;
      mbsEnter: c1 := FGradientSet.Enter;
    end;
    case towhich of
      mbsDown: c2 := FGradientSet.Down;
      mbsLeave: c2 := FGradientSet.Leave;
      mbsEnter: c2 := FGradientSet.Enter;
    end;
  end;

  if FAnimations.FFadeAnimation then
    Result := ColorBlend(c1, c2, progress * (255 div FAnimations.FASpeed))
  else
    Result := c2;
end;

function CButton.FadeFontColor(from, towhich: CButtonState;
  progress: integer): TColor;
var
  c1, c2: TColor;
begin
  c1 := clWhite;
  c2 := clWhite;

  case from of
    mbsDown: c1 := FTextColors.Down;
    mbsLeave: c1 := FTextColors.Leave;
    mbsEnter: c1 := FTextColors.Enter;
  end;
  case towhich of
    mbsDown: c2 := FTextColors.Down;
    mbsLeave: c2 := FTextColors.Leave;
    mbsEnter: c2 := FTextColors.Enter;
  end;

  if FAnimations.FFadeAnimation then
    Result := ColorBlend(c1, c2, progress * (255 div FAnimations.FASpeed))
  else
    Result := c2;
end;

procedure CButton.FTimerAct(Sender: TObject);
begin
  if NOT (FAnimations.TimeProg >= FAnimations.FASpeed) then
  begin
    inc(FAnimations.TimeProg);
     Paint;
  end else
  FadeAnim.Enabled := false;
end;

procedure CButton.Invalidate;
begin
  inherited;
  CheckForGlobalSync;
  Paint;

  ApplyAccentColor;
end;

procedure CButton.KeyPress(var Key: Char);
begin
  inherited;
  if key = #13 then begin
    SetState(mbsDown);
    if Assigned(FOnStateChange) then FOnStateChange(Self, FState);
    //if Assigned(OnClick) then OnClick(Self);
    SetState(mbsEnter);
    Click;
  end;
end;

procedure CButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: integer);
begin
  inherited;
  try
    Self.SetFocus;
  except
    RaiseLastOSError;
  end;
  SetState(mbsDown);
  if Assigned(FOnStateChange) then FOnStateChange(Self, FState);
  Animation(false);
end;

procedure CButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: integer);
begin
  inherited;
  if Self.Parent = nil then
    Exit;

  SetState(mbsEnter);
  if Assigned(FOnStateChange) then FOnStateChange(Self, FState);
  Paint;
  Animation(true);
end;

procedure CButton.Paint;
var
  I, TLeft, TTop, ILeft, ITop, SLeft, STop, SHeight, SWidth, IWidth, IHeight,
    TWidth, THeight, BOpacity, SC: Integer;
  cl2: TColor;
  IcoText, TText: string;
  drawcanv, lastcanv: TBitMap;
  CRect, DRect: TRect;
  TmpFont: TFont;
begin
  inherited;
  // Invalid
  if (Parent = nil) or (csDestroying in ComponentState) or FIsDestroy then
    Exit;

  // Global Sync
  CheckForGlobalSync;

  // Accent
  ApplyAccentColor;
  ApplyPreset(FPreset);

  // Pen Background
  if FPen.FSyncBgColor then
  begin
    if StrInArray(TStyleManager.ActiveStyle.Name, nothemes) then begin
      FPen.Color := GetParentForm(Self).Color;
    end else
      FPen.Color := TStyleManager.ActiveStyle.GetSystemColor(clBtnFace);
  end else
  begin
    if Self.ParentColor then
      FPen.Color := TStyleManager.ActiveStyle.GetSystemColor(Self.color);
  end;

  drawcanv := TBitMap.Create;
  drawcanv.Height := height;
  drawcanv.Width := width;

  with drawcanv.Canvas do begin
    //Drawing ( + Transparency )
    Brush.Color := FPen.Color;
    if FPen.FEnablePenAlt then begin
      if FState = mbsDown then Brush.Color := FPen.FCPenDown
        else
      if FState = mbsEnter then Brush.Color := FPen.FCPenHover;
    end;
    //bgcolor := Brush.Color;
    FillRect( ClipRect );

    Font.Assign( FFont );
    case FState of
      mbsLeave: begin
        Brush.Color := FColors.Leave;
        Font.Color := FTextColors.Leave;
      end;
      mbsEnter: begin
        Brush.Color := FColors.Enter;
        Font.Color := FTextColors.Enter;
      end;
      mbsDown: begin
        Brush.Color := FColors.Down;
        Font.Color := FTextColors.Down;
      end;
    end;

    { Animate }
    Brush.Color := FadeBrushColor( FPreviousState, FState, FAnimations.TimeProg);
    Font.Color := FadeFontColor( FPreviousState, FState, FAnimations.TimeProg);
    if FFlatBt then
      begin
        Font.Color := Brush.Color;
        Brush.Color := FadeBrushColor( FPreviousState, FState, FAnimations.TimeProg, true);
      end;

    //Brush.Color := clRed;
    // Normal Draw
    DRect := Rect( FPen.Width, FPen.Width, Width - FPen.Width, Height - FPen.Width );
    if NOT Self.Enabled then
      begin
        if FFlatBt then
          Font.Color := FTextColors.FLine
        else
          Brush.Color := ClrGray(Brush.Color);
      end;

    // Gradient Mode
    if FGradientSet.FEnabled then
    begin
      cl2 := FadeBrushColor( FPreviousState, FState, FAnimations.TimeProg, false, true);

      // Draw Gradient
      GradHorizontal(drawcanv.Canvas, DRect, Brush.Color, cl2);
    end
      else
    FillRect( DRect );

    // Text and Icon
    // Font Auto Size
    if FFontAutoSize.FEnabled and (FText <> '') then
    begin
      Font.Size := trunc((Self.Width - Pen.Width) / (TextWidth(FText)) * 7);

      if FFontAutoSize.FMax <> -1 then
      if Font.Size > FFontAutoSize.FMax then
        Font.Size   := FFontAutoSize.FMax;

      if FFontAutoSize.FMin <> -1 then
      if Font.Size < FFontAutoSize.FMin then
        Font.Size   := FFontAutoSize.FMin;
    end;

    // Prep Text Output
    TText := FText;
    SC := 5;

    if NOT FEnableCaption then
      begin
        TText := '';
        SC := 0;
      end;

    // Height and positioning
    TLeft := 0;
    TTop := 0;
    ILeft := 0;
    ITop := 0;

    TWidth := TextWidth(TText);
    THeight := TextHeight(TText);

    IHeight := THeight;

    // Sub Text Sizing
    SLeft := 0;
    STop := 0;
    SWidth := 0;
    SHeight := 0;
    if FEnableSubText then
      begin
        FSubTextFont.Color := Font.Color;

        TmpFont := TFont.Create;
        TmpFont.Assign(Font);

        SHeight := TextHeight(FSubText);
        SWidth := TextWidth(FSubText);

        Font.Assign(TmpFont);
        TmpFont.Free;
      end;

    // Clear brush and begin
    Brush.Style := bsClear;
    if NOT Self.Enabled then Font.Color := ClrGray(Font.Color);
      { Check for Icons }
      case FCIcon of
        CButtonIcon.cicYes: IcoText := '✔';
        CButtonIcon.cicNo: IcoText := '❌';
        CButtonIcon.cicNoAllow: IcoText := '🚫';
        CButtonIcon.cicTrueYes: IcoText := '✅';
        CButtonIcon.cicWarning: IcoText := '⚠';
        CButtonIcon.cicQuestion: IcoText := '❔ ';
        CButtonIcon.cicRetry: IcoText := '🔁';
        CButtonIcon.cicDownload: IcoText := '▼ ';
        CButtonIcon.cicUpload: IcoText := '▲';
        CButtonIcon.cicStart: IcoText := '➤';
        CButtonIcon.cicNext: IcoText := 'ᐅ';
        CButtonIcon.cicBack: IcoText := 'ᐊ';
        CButtonIcon.cicUp: IcoText := 'ᐃ';
        CButtonIcon.cicDown: IcoText := 'ᐁ';
        CButtonIcon.cicArrow: IcoText := '➜';
        CButtonIcon.cicEnter: IcoText := '➥';
        CButtonIcon.cicSearch: IcoText := '🔎';
        CButtonIcon.cicSearchL: IcoText := '🔍';
        CButtonIcon.cicSegoeFluent: IcoText := FSegoeIcon;
      end;
      { Bitmap Mode }
      try
        if IHeight = 0 then IHeight := round(height / 1.2);
        if NOT (FBitmap.Graphic = nil) then
          begin
            IWidth := round(FBitMap.Width / (FBitMap.Height / IHeight));
            if IWidth > Width - FPen.Width * 2 then
              begin
                IWidth := round(width / 1.2);
                IHeight := round(FBitMap.Height / (FBitMap.Width / IWidth));
              end;
          end
        else
          IWidth := 0;

        if IWidth = 0 then
          IWidth := IHeight;

        { Image Layouts }
        if ((FImageLayout = cpTop) or (FImageLayout = cpBottom)) and (FBitmap.Graphic = nil)and (TText <> '') then
        begin
          Inc(IWidth,IWidth div 2);
          Inc(IHeight,IHeight div 2);
        end;

        if (FCIcon = cicNone) and (FBitmap.Graphic = nil) then
          begin
            IWidth := 0;
            IHeight := 0;
            SC := 0;
          end;

        { Layout coordinate set }
        case FImageLayout of
          cpLeft: begin
            TTop := Height div 2 - THeight div 2 - SHeight div 2;
            STop := TTop + SHeight;
            ITop := TTop;

            case FAlign of
              taCenter: begin
                TLeft := Width div 2 - TWidth div 2 + IWidth div 2;
                ILeft := TLeft - IWidth - SC;
              end;
              taLeftJustify: begin
                TLeft := Pen.Width + FTxtWSpace + SC * 2 + IWidth;
                ILeft := Pen.Width + FTxtWSpace + SC;
              end;
              taRightJustify: begin
                TLeft := Width - Pen.Width - FTxtWSpace - SC - TWidth;
                ILeft := TLeft - IWidth - SC;
              end;
            end;
          end;
          cpRight: begin
            TTop := Height div 2 - THeight div 2 - SHeight div 2;
            STop := TTop + SHeight;
            ITop := TTop;

            case FAlign of
              taCenter: begin
                TLeft := Width div 2 - TWidth div 2 - IWidth div 2;
                ILeft := TLeft + TWidth + SC;
              end;
              taLeftJustify: begin
                TLeft := Pen.Width + FTxtWSpace + SC;
                ILeft := TLeft + TWidth + SC;
              end;
              taRightJustify: begin
                TLeft := Width - Pen.Width - FTxtWSpace - SC * 2 - TWidth - IWidth;
                ILeft := Width - Pen.Width - FTxtWSpace - SC - IWidth;
              end;
            end;
          end;
          cpTop: begin
            TTop := Height div 2 - THeight div 2 + IHeight div 2 - SHeight div 2;
            STop := TTop + SHeight;
            ITop := TTop - SC - IHeight;

            case FAlign of
              taCenter: begin
                TLeft := Width div 2 - TWidth div 2;
                ILeft := Width div 2 - IWidth div 2;
              end;
              taLeftJustify: begin
                TLeft := Pen.Width + FTxtWSpace + SC;
                ILeft := Pen.Width + FTxtWSpace + SC;
              end;
              taRightJustify: begin
                TLeft := Width - Pen.Width - FTxtWSpace - SC - TWidth;
                ILeft := Width - Pen.Width - FTxtWSpace - SC - IWidth;
              end;
            end;
          end;
          cpBottom: begin
            TTop := Height div 2 - THeight div 2 - IHeight div 2 - SHeight div 2;
            STop := TTop + SHeight;
            ITop := TTop + SC + IHeight + SHeight;

            case FAlign of
              taCenter: begin
                TLeft := Width div 2 - TWidth div 2;
                ILeft := Width div 2 - IWidth div 2;
              end;
              taLeftJustify: begin
                TLeft := Pen.Width + FTxtWSpace + SC;
                ILeft := Pen.Width + FTxtWSpace + SC;
              end;
              taRightJustify: begin
                TLeft := Width - Pen.Width - FTxtWSpace - SC - TWidth;
                ILeft := Width - Pen.Width - FTxtWSpace - SC - IWidth;
              end;
            end;
          end;
        end;

        { Auto Extend Image }
        { I don't know this man, It's too complicated. I should just rebuild the 
          CButton component from the ground up... :/ }
        if FAutoExtendImage then
          case FImageLayout of
            cpLeft: ;
            cpRight: ;
            cpTop: ;
            cpBottom: ;
          end;

        { SubText Left }
        case FAlign of
          taLeftJustify: SLeft := TLeft;
          taRightJustify: SLeft := TLeft + TWidth - SWidth;
          taCenter: SLeft := Width div 2 - SWidth div 2;
        end;

        { Check empty text for bitmap only }
        if TText = '' then
        begin
          ILeft := Width div 2- IWidth div 2;
          //ITop := trunc(Height * 0.1);
          ITop := Height div 2 - IHeight div 2;
        end;

        { Draw Bitmap }
        if not (FBitmap.Graphic = nil) then begin
          FBitMap.Graphic.Transparent := true;

          if Self.Enabled then
            BOpacity := 255
          else
            BOpacity := 100;

          DrawHighQuality(Rect(
          {x1} ILeft,
          {y1} ITop,
          {x2} ILeft + IWidth,
          {y2} ITop + IHeight
           ),FBitMap.Graphic, BOpacity);
        end
          else
        { Draw Text Icon }
        begin
          TmpFont := TFont.Create;
          TmpFont.Assign(Font);

          Font := TFont.Create;
          if FCIcon = cicSegoeFluent then
            begin
              if (NOT FSegoeMetro) and (Screen.Fonts.IndexOf(FONT_SEGOE_FLUENT) <> -1) then
                Font.Name := FONT_SEGOE_FLUENT
              else
                Font.Name := FONT_SEGOE_METRO;
            end;
          Font.Color := TmpFont.Color;
          Font.Size := GetMaxFontSize(Self.Canvas, IcoText, IWidth, IHeight);

          if TText = '' then
            ILeft := Width div 2 - TextWidth(IcoText) div 2
          else
            ILeft := ILeft + (IWidth - TextWidth(IcoText)) div 2;

          ITop := ITop + (IHeight - TextHeight(IcoText)) div 2;

          TextOut(ILeft, ITop, IcoText);

          Font.Assign(TmpFont);
          TmpFont.Free;
        end;
      except
        TText := '🚫' + TText;
      end;

    // Draw Text
    TextOut(  TLeft, TTop, TText);

    // Sub Text
    if FEnableSubText then
      begin
        Font.Assign(FSubTextFont);
        TextOut(  SLeft, STop, FSubText);
      end;


    // Underline
    if FUnderLine.FUnderLn then begin
      Brush.Style := bsSolid;
      Brush.Color := FColors.BLine;
      if FUnderLine.FUnderLnRound then begin
        Pen.Color := FColors.BLine;
        Pen.Width := FUnderLine.FUnderThick;
        Brush.Style := bsClear;
        Pen.Style := psSolid;
        if NOT Self.Enabled then Pen.Color := ClrGray(Pen.Color);
        RoundRect( Rect( -Pen.Width div 2, -Pen.Width, Width + Pen.Width div 2, Height - FPen.Width), FRoundAmount, FRoundAmount * 3);
      end else begin
        FillRect( Rect( FPen.Width, Height - trunc( Height / 50 * FUnderLine.FUnderThick ), Width - FPen.Width, Height - FPen.Width) );
      end;
    end;

    // Round Amount
    if FTransparent then begin
      Brush.Style := bsClear;
      if FPen.FEnablePenAlt then
        case State of
          mbsLeave: Pen.Color := FPen.FColor;
          mbsEnter: Pen.Color := FPen.FCPenHover;
          mbsDown: Pen.Color := FPen.FCPenDown;
        end
      else
        Pen.Color := FPen.FColor;
        
      Pen.Width := 1;
      for I := 0 to FRoundAmount do
        RoundRect(0, 0, Width, Height, I, I);
      end;
  end;

  //CRect := Canvas.ClipRect;
  CRect := Rect(ShX div 2, ShY div 2, Width - round(ShX / 2), Height - round(ShY / 2));

  //Final Preparations to avoid flicker
  lastcanv := TBitMap.Create;
  lastcanv.Width := Width;
  lastcanv.Height := Height;

  with lastcanv do begin
    Canvas.Brush.Color := TStyleManager.ActiveStyle.GetSystemColor(Self.Color);
    Canvas.FillRect( Canvas.ClipRect );

    //Canvas.CopyRect( CRect,drawcanv.Canvas,drawcanv.Canvas.ClipRect );
    Canvas.DrawHighQuality(CRect, drawcanv);
  end;

  //Complete draw cycle
  { CopyRoundRect(lastcanv.Canvas, RoundRect(Canvas.ClipRect, FRoundAmount + 1, FRoundAmount + 1),
                Self.Canvas, Canvas.ClipRect, 2) }

  Canvas.CopyRect( lastcanv.Canvas.ClipRect,lastcanv.Canvas,lastcanv.Canvas.ClipRect );

  lastcanv.Free;
  drawcanv.Free;
end;

procedure CButton.SetAccentColor(const Value: CAccentColor);
begin
  FAccent := Value;

  if Value <> CAccentColor.None then
    ApplyAccentColor;

  Paint;
end;

procedure CButton.SetAlign(const Value: TAlignment);
begin
  FAlign := Value;
  Paint;
end;

procedure CButton.SetAutoExtendImage(const Value: boolean);
begin
  FAutoExtendImage := Value;
  Paint;
end;

procedure CButton.SetBitmap(Value: TPicture);
begin
  FBitmap.Assign(value);
  Invalidate;
end;

procedure CButton.SetCancel(const Value: boolean);
begin
  FCancel := Value;
end;

procedure CButton.SetDefault(const Value: boolean);
begin
  FDefault := Value;
end;

procedure CButton.SetEnabled(Value: Boolean);
begin
  inherited;
  Paint;
end;

procedure CButton.SetEnableSubText(const Value: boolean);
begin
  FEnableSubText := Value;
  Paint;
end;

procedure CButton.SetFCustColor(const Value: boolean);
begin
  FCustTColor := Value;
  Paint;
end;

procedure CButton.SetFlatComplete(const Value: boolean);
begin
  FFlatComplete := Value;

  if Value then
    FUnderline.Enable := false;

  Paint;
end;

procedure CButton.SetFlatnes(const Value: boolean);
begin
  FFlatBT := Value;
  Paint;
end;

procedure CButton.SetFMBTColor(const Value: TColor);
begin
  FMBTColor := Value;
  Paint;
end;

procedure CButton.SetFocus;
begin
  inherited;
  {//OutDated execution
  FState := mbsEnter;
  if Assigned(FOnStateChange) then FOnStateChange(Self, FState);
  Paint;   }
end;

procedure CButton.SetFont(const Value: TFont);
begin
  FFont.Assign( Value );
  Paint;
end;

procedure CButton.SetFontAutoSize(const Value: CButtonFontAutoSize);
begin
  FFontAutoSize := Value;
end;

procedure CButton.SetGradient(const Value: CButtonGradientSet);
begin
  FGradientSet := Value;
  Paint;
end;

procedure CButton.SetIcon(const Value: CButtonIcon);
begin
  FCIcon := Value;
  Paint;
end;

procedure CButton.SetImageLayout(const Value: CPosition);
begin
  FImageLayout := Value;
  Paint;
end;

procedure CButton.SetMetroIcon(const Value: boolean);
begin
  FSegoeMetro := Value;

  Paint;
end;

procedure CButton.SetRoundVal(const Value: integer);
begin
  FRoundAmount := Value;


  Paint;
end;

procedure CButton.SetSegoeIcon(const Value: string);
begin
  FSegoeIcon := Value;

  Paint;
end;

procedure CButton.SetShowCaption(const Value: boolean);
begin
  FEnableCaption := Value;
  Paint;
end;

procedure CButton.SetState(const Value: CButtonState);
begin
  StTimer;
  FPreviousState := FState;
  FState := Value;
  Paint;
end;

procedure CButton.SetSubFont(const Value: TFont);
begin
  FSubTextFont.Assign( Value );
  Paint;
end;

procedure CButton.SetSubText(const Value: string);
begin
  FSubText := Value;
  Paint;
end;

procedure CButton.SetText(const Value: string);
begin
  FText := Value;
  Paint;
end;

procedure CButton.SetTextWall(const Value: integer);
begin
  FTxtWSpace := Value;

  Paint;
end;

procedure CButton.SetTransparent(const Value: boolean);
begin
  FTransparent := Value;
  Paint;
end;

procedure CButton.StTimer;
begin
  if Parent <> nil then
  if (Parent.Visible) and (Visible)
    and (Application.Active) and (FAnimations.FFadeAnimation)
    then begin
    FAnimations.TimeProg := 0;
    FadeAnim.Enabled := true;
  end;
end;

{ CButtonPresets }

function CButtonPresets.Paint: Boolean;
begin
  if Self.Owner is CButton then begin
    CButtOn(Self.Owner).Paint;
    Result := True;
  end else Result := False;
end;

{ CButtonUnderLine }

procedure CButtonUnderLine.SetUline(const Value: boolean);
begin
  FUnderLn := Value;
  CButton(Self.Owner).Paint;
end;

procedure CButtonUnderLine.SetULRound(const Value: boolean);
begin
  FUnderLnRound := Value;
  CButton(Self.Owner).Paint;
end;

procedure CButtonUnderLine.SetUlThick(const Value: integer);
begin
  FUnderThick := Value;
  CButton(Self.Owner).Paint;
end;

{ CButtonFontAutoSize }

function CButtonFontAutoSize.Paint: Boolean;
begin
  if Self.Owner is CButton then begin
    CButton(Self.Owner).Paint;
    Result := True;
  end else Result := False;
end;

{ CButtonGradientSet }

function CButtonGradientSet.Paint: Boolean;
begin
  if Self.Owner is CButton then begin
    CButton(Self.Owner).Paint;
    Result := True;
  end else Result := False;
end;

end.
