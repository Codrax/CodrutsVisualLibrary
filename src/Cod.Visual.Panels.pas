﻿unit Cod.Visual.Panels;

interface

uses
  SysUtils,
  Classes,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ExtCtrls,
  Cod.ColorUtils,
  Cod.Graphics,
  Cod.SysUtils,
  Cod.Components;

type
  CPanel = class(TPanel)
    public
      constructor Create(AOwner : TComponent); override;
      destructor Destroy; override;

      procedure Invalidate; override;

    private
      FAccent: CAccentColor;
      procedure SetUseAccentColor(const Value: CAccentColor);
      procedure ApplyAccentColor;

    published
      property UseAccentColor: CAccentColor read FAccent write SetUseAccentColor;

  end;

  CMinimisePanel = class(CPanel)
      constructor Create(AOwner : TComponent); override;
      destructor Destroy; override;
    private
      FHandleSize: integer;
      FHandleColor: TColor;
      FAutoHandleColor: boolean;
      FText: string;
      FMinimised: boolean;
      FAnimation: boolean;
      FHandleRound: integer;
      FUnderFill: boolean;
      FAutoCursor: boolean;
      FAutoFontColor: boolean;

      FBitmap: TBitMap;

      FAnGoTo, FAnStart: integer;
      FAnimTimer: TTimer;

      FAnimationSpeed: double;
      FPrevAutoSize: boolean;

      FSizeBeforeMin: integer;

      procedure DoneMinimise;

      procedure SetHandleSize(const Value: integer);
      procedure SetHandleRound(const Value: integer);
      procedure SetAutoHandeColor(const Value: boolean);
      procedure SetAccentFill(const Value: boolean);
      procedure StartToggle;
      procedure SetMinimiseState(statemin: boolean; instant: boolean = false);
      procedure SetMinimised(const Value: boolean);
      procedure AnimOnTimer(Sender: TObject);
      procedure SetBitMap(const Value: TBitMap);
      procedure SetText(const Value: string);
      procedure SetAutoColor(const Value: boolean);
      procedure SetAnimationSpeed(const Value: double);

    protected
      procedure Paint; override;

      procedure MouseUp(Button : TMouseButton; Shift: TShiftState; X, Y : integer); override;
      procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;

    public
      procedure ToggleMinimised;
      procedure ChangeMinimised(Minimised: boolean);

    published
      property OnMouseEnter;
      property OnMouseLeave;
      property OnMouseDown;
      property OnMouseUp;
      property OnMouseMove;
      property OnClick;

      property Align;
      property Anchors;
      property Cursor;
      property Visible;
      property Enabled;
      property Constraints;
      property DoubleBuffered;

      property HandleText: string read FText write SetText;
      property HandleSize: integer read FHandleSize write SetHandleSize;
      property HandleRoundness: integer read FHandleRound write SetHandleRound;
      property AutomaticHandleColor: boolean read FAutoHandleColor write SetAutoHandeColor;

      property IsMinimised: boolean read FMinimised write SetMinimised;
      property AccentShadeFill: boolean read FUnderFill write SetAccentFill;

      property AnimationSpeed: double read FAnimationSpeed write SetAnimationSpeed;
      property Animation: boolean read FAnimation write FAnimation;
      property Icon: TBitMap read FBitmap write SetBitMap;

      property AutomaticFontColor: boolean read FAutoFontColor write SetAutoColor;
      property DynamicCursor: boolean read FAutoCursor write FAutoCursor;
  end;

implementation

{ CProgress }

procedure CMinimisePanel.AnimOnTimer(Sender: TObject);
var
  speed: integer;
begin
  speed := 1;
  try
    //speed := trunc(abs(FAnGoTo - Height) / abs(FAnGoTo - FAnStart) * FSizeBeforeMin / 15);
    speed := trunc(abs(FAnGoTo - Height) / (11 - FAnimationSpeed));
  except end;

  if speed <= 0 then
    speed := 1;

  if FAnGoTo < Height then
    Height := Height + speed * -1;

  if FAnGoTo > Height then
    Height := Height + speed;

  if FAnGoTo = Height then
    begin
      FAnimTimer.Enabled := false;

      // Done
      DoneMinimise;
    end;
end;

procedure CMinimisePanel.ChangeMinimised(Minimised: boolean);
begin
  SetMinimiseState(Minimised);
end;

constructor CMinimisePanel.Create(AOwner: TComponent);
begin
  inherited;
  Width := 350;
  Height := 200;

  ParentBackground := true;
  ShowCaption := false;
  TabStop := true;

  FAnimTimer := TTimer.Create(Self);
  with FAnimTimer do begin
    Interval := 1;
    Enabled := false;
    OnTimer := AnimOnTimer;
  end;

  Font.Size := 10;
  Font.Name := 'Segoe Ui';

  if FBitMap = nil then
    FBitMap := TBitMap.Create;

  FAutoHandleColor := true;
  FHandleColor := clWhite;;
  FHandleRound := 20;

  FUnderFill := true;

  FAutoFontColor := true;

  FAnimationSpeed := 3.5;

  DoubleBuffered := true;

  FAnimation := true;
  FText := 'Minimised Panel';

  ParentColor := true;

  FHandleSize := 30;
end;

destructor CMinimisePanel.Destroy;
begin
  FAnimTimer.Enabled := false;
  FreeAndNil(FAnimTimer);
  FBitMap.Free;
  inherited;
end;

procedure CMinimisePanel.DoneMinimise;
begin
  if not FMinimised then
    AutoSize := FPrevAutoSize;
end;

procedure CMinimisePanel.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if FAutoCursor then
    begin
      if Y <= FHandleSize then
        Cursor := crHandPoint
      else
        Cursor := crDefault;
    end;
end;

procedure CMinimisePanel.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: integer);
begin
  inherited;
  if Y <= FHandleSize then
    StartToggle;
end;

procedure CMinimisePanel.Paint;
var
  tleft: integer;
  tmp: TBitMap;
  i: string;
  SColor: TColor;
begin
  inherited;
  tmp := TBitMap.Create;
  tmp.Height := Height;
  tmp.Width := Width;

  SColor := ColorToRGB(Self.Color);

  with tmp.canvas do begin
    Brush.Color := SColor;
    FillRect(cliprect);

    Font.Assign(Self.Font);

    Pen.Style := psClear;

    if FUnderFill then
      begin
        if GetColorSat(SColor) >= 45  then
          Brush.Color := ChangeColorSat(SColor, -5)
        else
          Brush.Color := ChangeColorSat(SColor, 5);

        RoundRect(0, 0, Width, Height, FHandleRound, FHandleRound);
      end;

    if FAutoFontColor then
      begin
        if GetColorSat(SColor) >= 75 then
          Font.Color := clBlack
        else
          Font.Color := clWhite
      end;

    Brush.Color := FHandleColor;

    if FAutoHandleColor then
      begin
        if GetColorSat(SColor) >= 45  then
          Brush.Color := ChangeColorSat(SColor, -30)
        else
          Brush.Color := ChangeColorSat(SColor, 30);
      end;


    RoundRect(0, 0, Width, FHandleSize, FHandleRound, FHandleRound);

    if NOT FBitMap.Empty then
    begin
      tleft := trunc(FHandleSize * 1.1);

      FBitMap.Transparent := true;
      FBitMap.TransparentMode := tmAuto;

      StretchDraw(Rect(3, 3, FHandleSize - 3, FHandleSize - 3), FBitMap);
    end
      else
        tleft := 10;

    Brush.Style := bsClear;
    TextOut(tleft, FHandleSize div 2 - TextHeight(FText) div 2, FText);

    Pen.Style := psSolid;

    if FMinimised then
      i := '▼'
    else
      i := '▲';

    Font.Size := GetMaxFontSize(tmp.Canvas, i, Width, FHandleSize);

    TextOut(Width - TextWidth(i) - 10, FHandleSize div 2 - TextHeight(i) div 2 - 3, i);
  end;

  canvas.CopyRect(canvas.ClipRect, tmp.Canvas, canvas.ClipRect);
end;

procedure CMinimisePanel.SetAccentFill(const Value: boolean);
begin
  FUnderFill := Value;

  Paint;
end;

procedure CMinimisePanel.SetAnimationSpeed(const Value: double);
begin
  FAnimationSpeed := Value;

  if FAnimationSpeed > 10 then
    FAnimationSpeed := 10;
end;

procedure CMinimisePanel.SetAutoColor(const Value: boolean);
begin
  FAutoFontColor := Value;

  Paint;
end;

procedure CMinimisePanel.SetAutoHandeColor(const Value: boolean);
begin
  FAutoHandleColor := Value;

  Paint;
end;

procedure CMinimisePanel.SetBitMap(const Value: TBitMap);
begin
  FBitmap.Assign(Value);

  Paint;
end;

procedure CMinimisePanel.SetHandleRound(const Value: integer);
begin
  FHandleRound := Value;

  Paint;
end;

procedure CMinimisePanel.SetHandleSize(const Value: integer);
begin
  FHandleSize := Value;

  if FMinimised then
    Self.Height := Value;
end;

procedure CMinimisePanel.SetMinimised(const Value: boolean);
begin
  FMinimised := Value;

  SetMinimiseState(Value, true);
end;

procedure CMinimisePanel.SetMinimiseState(statemin: boolean; instant: boolean);
begin
  // Exit
  if statemin = FMinimised then
    Exit;

  FMinimised := NOT FMinimised;

  // Animation Timer
  if FAnimTimer.Enabled then
  begin
    if statemin then
      FAnGoTo := FHandleSize
    else
      FAnGoTo := FSizeBeforeMin;

    Exit;
  end;

  // Minimised State
  if statemin then
    begin
      FSizeBeforeMin := Height;
      FPrevAutoSize := AutoSize;

      // Requirements
      AutoSize := false;
    end;

  // Instant
  if (NOT FAnimation) or Instant then
  begin
    if statemin then
      Height := FHandleSize
    else
      Height := FSizeBeforeMin;

    // Done
    DoneMinimise;
  end
    else
  // Animation Based
  begin
    FAnStart := Height;

    if statemin then
      FAnGoTo := FHandleSize
    else
      FAnGoTo := FSizeBeforeMin;

    FAnimTimer.Enabled := true;
  end;
end;

procedure CMinimisePanel.SetText(const Value: string);
begin
  FText := Value;

  Paint;
end;

procedure CMinimisePanel.StartToggle;
begin
  SetMinimiseState(NOT FMinimised)
end;

procedure CMinimisePanel.ToggleMinimised;
begin
  StartToggle;
end;

{ CPanel }

procedure CPanel.ApplyAccentColor;
var
  AccColor: TColor;
begin
  if FAccent = CAccentColor.None then
    Exit;

  AccColor := GetAccentColor(FAccent);

  Self.Color := AccColor;
end;

constructor CPanel.Create(AOwner: TComponent);
begin
  inherited;

  BevelKind := bkNone;
  BevelOuter := bvNone;

  FAccent := CAccentColor.None;
end;

destructor CPanel.Destroy;
begin

  inherited;
end;

procedure CPanel.Invalidate;
begin
  inherited;

  ApplyAccentColor;
end;

procedure CPanel.SetUseAccentColor(const Value: CAccentColor);
begin
  FAccent := Value;

  if Value <> CAccentColor.None then
    ParentColor := false;
  Invalidate;
end;

end.
