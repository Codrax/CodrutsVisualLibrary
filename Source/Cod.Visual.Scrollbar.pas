unit Cod.Visual.Scrollbar;

interface
uses
  Classes,
  Messages,
  Windows,
  Vcl.Controls,
  Vcl.Graphics,
  Types,
  Math,
  UITypes,
  SysUtils,
  Vcl.ExtCtrls,
  Cod.Types,
  Cod.Components,
  Cod.VarHelpers,
  Cod.ColorUtils,
  Cod.Graphics;

type
  CScrollbar = class;

  COrientation = (coHorizontal, coVertical);

  CScrollbarColors = class(TMPersistent)
  private
    FForeground,
    FButtons,
    FContent: TColor;
    function Paint : Boolean;
  published
    property Foreground: TColor read FForeground write FForeground stored Paint;
    property Buttons: TColor read FButtons write FButtons stored Paint;
    property Content: TColor read FContent write FContent stored Paint;
  end;

  CScrollbar = class(TCustomControl)
    private
      var DrawRect, SliderRect, Button1, Button2: TRect;
      FOnChange: TNotifyEvent;
      FOrientation: COrientation;
      FRoundness: integer;
      FPosition, FMin, FMax: int64;
      FSmallChange,
      FScrollBarHeight,
      FCustomScrollBarHeight: integer;
      FPageSize: integer;
      FSliderSpacing: integer;
      FEnableButtons: boolean;
      FRepeater: TTimer;
      FAutoMinimise: boolean;
      FBackgroundColor: TColor;
      FSliderSize: integer;
      FMinimised: boolean;
      FPreferLeftSide: boolean;

      FAnimation: boolean;
      FAnimPos: integer;
      FAnim: TTimer;
      FState: CControlState;
      FTemp: TBitMap;

      FPressInitiated: boolean;

      FDrawColors: CScrollbarColors;

      Contains1, Contains2: boolean;
      FAutoRoundness: boolean;
      FCustomRoundness: integer;

      // Update
      procedure UpdateRects;

      // Timer
      procedure RepeaterExecute(Sender: TObject);
      procedure AnimationExecute(Sender: TObject);

      // Animation
      procedure SetMinimisedState(Value: boolean);
      function GetSliderSize(AMinimised: boolean): integer;

      // Set
      procedure SetOrientation(const Value: COrientation);
      procedure SetMax(const Value: int64);
      procedure SetMin(const Value: int64);
      procedure SetPosition(const Value: int64);

      // Messages
      procedure WM_LButtonUp(var Msg: TWMLButtonUp); message WM_LBUTTONUP;
      procedure SetSmallChange(const Value: integer);

      // Buttons
      function GetButtonsSize: integer;
      procedure SetEnableButtons(const Value: boolean);
      procedure SetCustomScrollbarSize(const Value: integer);
      procedure SetPageSize(const Value: integer);
      procedure SetRoundness(const Value: integer);
      procedure SetAutoRoundness(const Value: boolean);

    protected
      procedure Paint; override;
      procedure WMSize(var Message: TWMSize); message WM_SIZE;

      // Inherited Mouse Detection
      procedure MouseDown(Button : TMouseButton; Shift: TShiftState; X, Y : integer); override;
      procedure MouseUp(Button : TMouseButton; Shift: TShiftState; X, Y : integer); override;
      procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
      procedure CMMouseEnter(var Message : TMessage); message CM_MOUSEENTER;
      procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;

      procedure KeyPress(var Key: Char); override;

    published
      property Colors: CScrollbarColors read FDrawColors write FDrawColors stored true;
      property OnChange: TNotifyEvent read FOnChange write FOnChange;
      property Orientation: COrientation read FOrientation write SetOrientation default coVertical;
      property Position: int64 read FPosition write SetPosition;
      property SmallChange: integer read FSmallChange write SetSmallChange default 1;
      property Min: int64 read FMin write SetMin default 0;
      property Max: int64 read FMax write SetMax default 100;
      property Animation: boolean read FAnimation write FAnimation;

      property Minimised: boolean read FMinimised write FMinimised;
      property AutoRoundness: boolean read FAutoRoundness write SetAutoRoundness;
      property Roundness: integer read FCustomRoundness write SetRoundness;
      property CustomScrollbarSize: integer read FCustomScrollBarHeight write SetCustomScrollbarSize;
      property PageSize: integer read FPageSize write SetPageSize default 1;
      property EnableButtons: boolean read FEnableButtons write SetEnableButtons default true;
      property AutoMinimise: boolean read FAutoMinimise write FAutoMinimise default true;
      property PreferLeftSide: boolean read FPreferLeftSide write FPreferLeftSide default false;
      property Align;
      property Constraints;
      property Anchors;
      property Hint;
      property ShowHint;
      property TabStop;
      property TabOrder;
      property OnEnter;
      property OnExit;
      property OnClick;
      property OnKeyDown;
      property OnKeyUp;
      property OnKeyPress;
      property OnMouseUp;
      property OnMouseDown;
      property OnMouseEnter;
      property OnMouseLeave;

      property Color;
      property ParentColor;

    public
      constructor Create(aOwner: TComponent); override;
      destructor Destroy; override;

      function GetPercentage: real;
      function GetPercentageCustom(Value: int64): real;
  end;

const
  SCROLLBAR_DEFAULT_SIZE = 40;
  SCROLLBAR_MIN_SIZE = 20;

implementation

procedure CScrollbar.KeyPress(var Key: Char);
begin
  inherited;
  if (key = '-') or (key = '+') then
    begin
      if Key = '-' then
        Position := Position - FSmallChange
      else
        Position := Position + FSmallChange;
    end;
end;

procedure CScrollbar.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: integer);
var
  P: TPoint;
begin
  inherited;
  // Move Detection
  FState := CControlState.Down;
  MouseMove([], X, Y);

  // Down
  P := Point(X, Y);
  if EnableButtons then
    if not (Contains1 or Contains2) then
      FPressInitiated := true;

  // Contains
  if Contains1 or Contains2 then
    begin
      RepeaterExecute(nil);

      FRepeater.Interval := 500;
      FRepeater.Enabled := true;
    end;
end;

procedure CScrollbar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  NewPosition: int64;
  P: TPoint;
begin
  inherited;
  // Point
  P := Point(X, Y);

  // Buttons
  Contains1 := false;
  Contains2 := false;

  if EnableButtons and not FPressInitiated then
    begin
      Contains1 := Button1.Contains(P);
      Contains2 := Button2.Contains(P);
    end;

  // Change Position
  if FPressInitiated then
    begin
      if FMax = FMin then
        NewPosition := FMin
      else
        begin
          if Orientation = coHorizontal then
            NewPosition := round((X - FScrollBarHeight / 2) / (Width - FScrollBarHeight) * (FMax - FMin))
          else
            NewPosition := round((Y - FScrollBarHeight / 2) / (Height - FScrollBarHeight) * (FMax - FMin));
        end;

      Position := NewPosition + FMin;
    end;
end;

procedure CScrollbar.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: integer);
begin
  inherited;
  FState := CControlState.Enter;
end;

procedure CScrollbar.UpdateRects;
var
  MaxPossibleLength,
  MaxPosition: integer;
  ButtonsSize: integer;
  SliderSize: integer;
procedure CalculateScrollbarHeight;
begin
  // Scrollbar Size
  if CustomScrollbarSize > 0 then
    FScrollBarHeight := CustomScrollbarSize
  else
    begin
      if PageSize > 1 then
        FScrollBarHeight := Math.Max( trunc(GetPercentageCustom(PageSize) * MaxPossibleLength), SCROLLBAR_MIN_SIZE)
      else
        FScrollBarHeight := SCROLLBAR_DEFAULT_SIZE;
    end;
end;
begin
  DrawRect := Rect(0, 0, Width, Height);

  // Apply by orientation
  if FOrientation = coHorizontal then
    begin
      // Slider
      SliderRect := DrawRect;
      SliderSize := DrawRect.Height;

      // Button Rect
      Button1 := Rect(0, 0, SliderSize, SliderSize);
      Button2 := Button1;
      Button2.Offset(Width - SliderSize, 0);

      ButtonsSize := GetButtonsSize;

      // Value
      SliderRect.Inflate(-FSliderSpacing, -FSliderSpacing);
      MaxPossibleLength := SliderRect.Width - FSliderSpacing * 2 - ButtonsSize;
      CalculateScrollbarHeight;
      MaxPosition := MaxPossibleLength - FScrollBarHeight;

      SliderRect.Width := FScrollBarHeight;
      SliderRect.Offset( SliderRect.Left + ButtonsSize div 2 + trunc(GetPercentage * MaxPosition),
        0
        );

      // Round
      FRoundness := DrawRect.Height div 2;
    end
  else
    begin
      // Slider
      SliderRect := DrawRect;
      SliderSize := DrawRect.Width;

      // Button Rect
      Button1 := Rect(0, 0, SliderSize, SliderSize);
      Button2 := Button1;
      Button2.Offset(0, Height - SliderSize);

      ButtonsSize := GetButtonsSize;

      // Value
      SliderRect.Inflate(-FSliderSpacing, -FSliderSpacing);
      MaxPossibleLength := SliderRect.Height - FSliderSpacing * 2 - ButtonsSize;
      CalculateScrollbarHeight;
      MaxPosition := MaxPossibleLength - FScrollBarHeight;

      SliderRect.Height := FScrollBarHeight;
      SliderRect.Offset( 0,
        SliderRect.Top + ButtonsSize div 2 + trunc(GetPercentage * MaxPosition)
        );

      // Round
      FRoundness := DrawRect.Width div 2;
    end;

  // Custom Round
  if not AutoRoundness then
    begin
      FRoundness := FCustomRoundness;
      if FRoundness = 0 then
        FRoundness := 1;
    end;

  // Re-Minimise
  if (csDesigning in ComponentState) and AutoMinimise and (FState = CControlState.Leave) and not FMinimised then
    FMinimised := true;

  // Minimised State
  SetMinimisedState(FMinimised);
end;

procedure CScrollbar.CMMouseEnter(var Message: TMessage);
begin
  SetMinimisedState( false );

  FState := CControlState.Enter;
  UpdateRects;
  Paint;

  inherited;
end;

procedure CScrollbar.CMMouseLeave(var Message: TMessage);
begin
  SetMinimisedState( true );

  FState := CControlState.Leave;
  UpdateRects;
  Paint;

  inherited;
end;

constructor CScrollbar.Create(aOwner: TComponent);
begin
  inherited;
  FOrientation := coVertical;
  FSmallChange := 1;
  FScrollBarHeight := 90;
  FEnableButtons := true;
  FPageSize := 1;
  FCustomScrollBarHeight := 0;
  FTemp := TBitMap.Create;

  FPosition := 0;
  FMin := 0;
  FMax := 100;
  FAutoRoundness := true;

  FSliderSpacing := 3;
  FAutoMinimise := true;
  FAnimation := true;

  // Repeater
  FRepeater := TTimer.Create(nil);
  with FRepeater do
    begin
      Interval := 500;
      Enabled := false;
      OnTimer := RepeaterExecute;
    end;

  // Animation
  FAnim := TTimer.Create(nil);
  with FAnim do
    begin
      Interval := 10;
      Enabled := false;
      OnTimer := AnimationExecute;
    end;

  // Custom Color
  FDrawColors := CScrollBarColors.Create(Self);
  with FDrawColors do
    begin
      FForeground := CColors.Gray;
      FButtons := CColors.LtGray;
      FContent := CColors.LtGray;
    end;

  // Sizing
  Height := 225;
  Width := 12;

  // Update
  UpdateRects;
end;

destructor CScrollbar.Destroy;
begin
  FreeAndNil( FDrawColors );
  FreeAndNil( FRepeater );
  FreeAndNil( FAnim );
  FreeAndNil( FTemp );
  inherited;
end;

function CScrollbar.GetButtonsSize: integer;
begin
  if not FEnableButtons then
    Result := 0
  else
    if Orientation = coHorizontal then
      Result := Button1.Width + Button2.Width
    else
      Result := Button1.Height + Button2.Height;
end;

function CScrollbar.GetPercentage: real;
begin
  Result := GetPercentageCustom(FPosition);
end;

function CScrollbar.GetPercentageCustom(Value: int64): real;
var
  Value1, Value2: int64;
begin
  Result := 0;
  Value1 := Value - FMin;
  Value2 := FMax - FMin;
  if Value1 < 0 then
    begin
      Inc(Value2, abs(Value1));
      Inc(Value1, abs(Value1));
    end;
  if Value2 <> 0 then
    Result := Value1 / Value2;
end;

function CScrollbar.GetSliderSize(AMinimised: boolean): integer;
begin
  if Orientation = coHorizontal then
    begin
      Result := SliderRect.Height div 2;
    end
  else
    begin
      Result := SliderRect.Width div 2;
    end;
end;

procedure CScrollbar.Paint;
var
  Points: TArray<TPoint>;
  Spacing1, Spacing2, Shrinked: integer;
  ARect: TRect;
begin
  // Draw slider
  Canvas.Brush.Style := bsClear;
  Canvas.Font.Assign(Font);

  Canvas.Draw(0, 0, FTemp);

  FTemp.Width := Width;
  FTemp.Height := Height;
  with FTemp.Canvas do
    begin
      // Fill background
      Pen.Style := psClear;
      Brush.Color := Color;
      FillRect(ClipRect);

      // Slider Background
      GDIRoundRect(MakeRoundRect(ClipRect, FRoundness*2), GetRGB(FBackgroundColor).MakeGDIBrush, nil);

      // Full
      ARect := SliderRect;
      Brush.Color := FDrawColors.ForeGround;

      if FMinimised then
        begin
          if Orientation = coHorizontal then
            begin
              ARect.Height := FSliderSize;

              if not FPreferLeftSide then
                ARect.Offset(0, ARect.Height);
            end
          else
            begin
              ARect.Width := FSliderSize;

              if not FPreferLeftSide then
                ARect.Offset(ARect.Width, 0);
            end;
        end;

      GDIRoundRect(MakeRoundRect(ARect, FRoundness), GetRGB(Brush.Color).MakeGDIBrush, nil);
    end;

  // Draw Buttons
  if EnableButtons and not FMinimised then
    with FTemp.Canvas do
      begin
        Brush.Color := FDrawColors.Buttons;
        Pen.Style := psClear;

        // Shrink
        Spacing1 := round(FSliderSpacing/2);
        Spacing2 := Spacing1;
        Shrinked := FSliderSpacing;

        // Press
        if FState = CControlState.Down then
          begin
            if Contains1 then
              Spacing1 := Shrinked;

            if Contains2 then
              Spacing2 := Shrinked;
          end;

        SetLength(Points, 3);
        if Orientation = coHorizontal then
          begin
            // Button 1
            ARect := Button1;
            ARect.Left := ARect.Left + Shrinked;
            ARect.Inflate(-Spacing1, -Spacing1);
            Points[0] := Point(ARect.Left, ARect.CenterPoint.Y);
            Points[1] := Point(ARect.Right, ARect.Top);
            Points[2] := Point(ARect.Right, ARect.Bottom);

            Polygon(Points);

            // Button 2
            ARect := Button2;
            ARect.Right := ARect.Right - Shrinked;
            ARect.Inflate(-Spacing2, -Spacing2);
            Points[0] := Point(ARect.Right, ARect.CenterPoint.Y);
            Points[1] := Point(ARect.Left, ARect.Top);
            Points[2] := Point(ARect.Left, ARect.Bottom);

            Polygon(Points);
          end
        else
          begin
            // Button 1
            ARect := Button1;
            ARect.Top := ARect.Top + Shrinked;
            ARect.Inflate(-Spacing1, -Spacing1);
            Points[0] := Point(ARect.CenterPoint.X, ARect.Top);
            Points[1] := Point(ARect.Right, ARect.Bottom);
            Points[2] := Point(ARect.Left, ARect.Bottom);

            Polygon(Points);

            // Button 2
            ARect := Button2;
            ARect.Bottom := ARect.Bottom - Shrinked;
            ARect.Inflate(-Spacing2, -Spacing2);
            Points[0] := Point(ARect.CenterPoint.X, ARect.Bottom);
            Points[1] := Point(ARect.Right, ARect.Top);
            Points[2] := Point(ARect.Left, ARect.Top);

            Polygon(Points);
          end;
      end;

  // Copy Temp Buffer
  Canvas.Draw(0, 0, FTemp);

  inherited;
end;

procedure CScrollbar.RepeaterExecute(Sender: TObject);
begin
  FRepeater.Interval := 50;

  if Contains1 then
    Position := Position - SmallChange;
  if Contains2 then
    Position := Position + SmallChange;
end;

procedure CScrollbar.SetEnableButtons(const Value: boolean);
begin
  if FEnableButtons <> Value then
    begin
      FEnableButtons := Value;
      Paint;
    end;
end;

procedure CScrollbar.SetMax(const Value: int64);
begin
  if FMax <> Value then
    begin
      FMax := Value;

      if not (csReading in ComponentState) then
        begin
          if FMin > FMax then
            FMax := FMax;

          if FPosition > FMax then
            FPosition := FMax;
        end;

      UpdateRects;
      Paint;
    end;
end;

procedure CScrollbar.SetMin(const Value: int64);
begin
  if FMin <> Value then
    begin
      FMin := Value;

      if not (csReading in ComponentState) then
        begin
          if FPosition < FMin then
            FPosition := FMin;

          if FMax < FMin then
            FMax := FMin;
        end;

      UpdateRects;
      Paint;
    end;
end;

procedure CScrollbar.SetMinimisedState(Value: boolean);
begin
  // Animation
  if (FMinimised <> Value) and FAnimation and not (csDesigning in ComponentState) then
    begin
      FAnimPos:= 0;

      FAnim.Enabled := true;
    end;

  // Set
  FMinimised := Value;

  // Data
  FSliderSize := GetSliderSize(Value);

  // Update
  if Value then
    begin
      FBackgroundColor := Color;
    end
  else
    begin
      FBackgroundColor := FDrawColors.Content;
    end;
end;

procedure CScrollbar.SetOrientation(const Value: COrientation);
var
  AWidth: integer;
begin
  if (FOrientation <> Value) then
    begin
      FOrientation := Value;

      if not (csReading in ComponentState) then
        begin
          AWidth := Width;
          Width := Height;
          Height := AWidth;

          UpdateRects;
          Paint;
        end;
    end;
end;

procedure CScrollbar.SetPageSize(const Value: integer);
begin
  if (FPageSize <> Value) and (Value > 0) then
    begin
      FPageSize := Value;

      UpdateRects;
      Paint;
    end;
end;

procedure CScrollbar.SetPosition(const Value: int64);
begin
  if FPosition <> Value then
    begin
      FPosition := Value;

      if not (csReading in ComponentState) then
        begin
          if FPosition < FMin then
            FPosition := FMin;

          if FPosition > FMax then
            FPosition := FMax;

          if Assigned(OnChange) then
            OnChange(Self);
        end;

      UpdateRects;
      Paint;
    end;
end;

procedure CScrollbar.SetRoundness(const Value: integer);
begin
  if FCustomRoundness <> Value then
    begin
      FCustomRoundness := Value;
      
      if AutoRoundness then
        Paint;
    end;
end;

procedure CScrollbar.SetAutoRoundness(const Value: boolean);
begin
  if FAutoRoundness <> Value then
    begin
      FAutoRoundness := Value;

      UpdateRects;
      Paint;
    end;
end;

procedure CScrollbar.SetCustomScrollbarSize(const Value: integer);
begin
  if (FCustomScrollBarHeight <> Value) and (Value < Height) then
    begin
      FCustomScrollBarHeight := Value;

      UpdateRects;
      Paint;
    end;
end;

procedure CScrollbar.SetSmallChange(const Value: integer);
begin
  if FSmallChange <> Value then
    if Value > 0 then
      FSmallChange := Value;
end;

procedure CScrollbar.WMSize(var Message: TWMSize);
begin
  inherited;
  UpdateRects;
  Paint;
end;

procedure CScrollbar.WM_LButtonUp(var Msg: TWMLButtonUp);
begin
  inherited;
  FPressInitiated := false;
  if EnableButtons then
    Paint;

  FRepeater.Enabled := false;
end;

procedure CScrollbar.AnimationExecute(Sender: TObject);
begin
  Inc(FAnimPos, 15);

  // Draw
  if FMinimised then
    begin
      FBackgroundColor := ColorBlend(FDrawColors.Content, Color, FAnimPos);
    end
  else
    begin
      FBackgroundColor := ColorBlend(Color, FDrawColors.Content, FAnimPos);
    end;

  Paint;

  // Stop
  if FAnimPos = 255 then
    begin
      FAnim.Enabled := false;
    end;
end;

{ CScrollbarColors }

function CScrollbarColors.Paint: Boolean;
begin
  if Self.Owner is CScrollbar then begin
    CScrollbar(Self.Owner).Paint;
    Result := True;
  end else Result := False;
end;

end.
