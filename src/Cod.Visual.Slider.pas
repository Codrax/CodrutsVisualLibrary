unit Cod.Visual.Slider;

interface

uses
  SysUtils,
  Classes,
  Vcl.Controls,
  Types,
  Vcl.ExtCtrls,
  Cod.Visual.CPSharedLib,
  Math,
  Vcl.Forms,
  WinApi.Windows,
  Vcl.Graphics,
  Vcl.Themes,
  Vcl.Styles,
  Cod.Components,
  Cod.Graphics,
  System.Messaging;

type
  CSlider = class;
  CSliderPreset = (cslNone);
  CSliderState = (cssLeave, cssEnter, cssDown);
  CSliderChange = procedure(Sender : CSlider; Position, Max, Min: integer) of object;

  CSliderForeground = class(TMPersistent)
    private
      FLeave, FEnter, FDown, FBorder: TColor;
      FBorderThick: integer;
      FMultiColor: boolean;
    published
      property Enter : TColor read FEnter write FEnter;
      property Leave : TColor read FLeave write FLeave;
      property Down : TColor read FDown write FDown;
      property Border : TColor read FBorder write FBorder;
      property BorderThick : integer read FBorderThick write FBorderThick;
      property MultiColor : boolean read FMultiColor write FMultiColor;
  end;

  CSliderBackground = class(TMPersistent)
    private
      FLeave, FEnter, FDown, FBorder: TColor;
      FBorderThick: integer;
      FMultiColor: boolean;
    published
      property Enter : TColor read FEnter write FEnter;
      property Leave : TColor read FLeave write FLeave;
      property Down : TColor read FDown write FDown;
      property Border : TColor read FBorder write FBorder;
      property BorderThick : integer read FBorderThick write FBorderThick;
      property MultiColor : boolean read FMultiColor write FMultiColor;
  end;

  CSliderIndicatorColor = class(TMPersistent)
    private
      FLeave, FEnter, FDown, FBorder: TColor;
      FBorderThick, FDynBorderThick: integer;
      FMultiColor, FDynamicBorder: boolean;
    published
      property Enter : TColor read FEnter write FEnter;
      property Leave : TColor read FLeave write FLeave;
      property Down : TColor read FDown write FDown;
      property Border : TColor read FBorder write FBorder;
      property BorderThick : integer read FBorderThick write FBorderThick;
      property MultiColor : boolean read FMultiColor write FMultiColor;

      property DynamicBorderSize : integer read FDynBorderThick write FDynBorderThick;
      property DynamicBorder : boolean read FDynamicBorder write FDynamicBorder;
  end;

  CSliderOptions = class(TMPersistent)
    private
      FHeight, FWidthMargin, FRoundness: integer;
      FFlatEnd: boolean;
    published
      property Height : integer read FHeight write FHeight;
      property WidthMargin : integer read FWidthMargin write FWidthMargin;
      property Roundness : integer read FRoundness write FRoundness;
      property FlatEnd: boolean read FFlatEnd write FFlatEnd;
  end;

  CSliderIndicator = class(TMPersistent)
    private
      FHeight, FWidth, FRoundness: integer;
      FEnabled: boolean;
    published
      property Height : integer read FHeight write FHeight;
      property Width : integer read FWidth write FWidth;
      property Roundness : integer read FRoundness write FRoundness;
      property Enabled : boolean read FEnabled write FEnabled;
  end;

  CSlider = class(TCustomTransparentControl)
      constructor Create(AOwner : TComponent); override;
      destructor Destroy; override;
    private
      FAuthor, FSite, FVersion: string;

      FBackground: CSliderBackground;
      FForeground: CSliderForeground;
      FOptions: CSliderOptions;
      FIndic: CSliderIndicator;
      FIndicColor: CSliderIndicatorColor;
      FPreset: CSliderPreset;
      FMax, FMin: integer;
      FPosition: integer;
      FAccent: CAccentColor;
      FOnChange : CSliderChange;
      FState: CSliderState;

      procedure SetMax(const Value: integer);
      procedure SetMin(const Value: integer);
      procedure SetPosition(const Value: integer);
      procedure SetPresets(const Value: CSliderPreset);
      procedure ApplyAccentColor;
      procedure SetAccentColor(const Value: CAccentColor);
     procedure SetState(const Value: CSliderState);
      procedure SetBackground(const Value: CSliderBackground);
      procedure SetForeground(const Value: CSliderForeground);
      procedure SetIndicator(const Value: CSliderIndicator);
      procedure SetIndicColor(const Value: CSliderIndicatorColor);
      procedure SetOptions(const Value: CSliderOptions);

    protected
      procedure Paint; override;

      procedure CMMouseEnter(var Message : TMessage); message CM_MOUSEENTER;
      procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
      procedure MouseDown(Button : TMouseButton; Shift: TShiftState; X, Y : integer); override;
      procedure MouseMove(Shift: TShiftState; X, Y : integer); override;
      procedure MouseUp(Button : TMouseButton; Shift: TShiftState; X, Y : integer); override;

    published
      property OnMouseEnter;
      property OnMouseLeave;
      property OnMouseDown;
      property OnMouseUp;
      property OnMouseMove;
      property OnClick;
      property OnChange : CSliderChange read FOnChange write FOnChange;

      property ShowHint;
      property Align;
      property Anchors;
      property Cursor;
      property Visible;
      property Enabled;
      property Constraints;
      property DoubleBuffered;

      property Color;
      property ParentBackground;
      property ParentColor;

      property AccentColor : CAccentColor read FAccent write SetAccentColor;
      property Presets : CSliderPreset read FPreset write SetPresets;
      property Foreground : CSliderForeground read FForeground write SetForeground;
      property Background : CSliderBackground read FBackground write SetBackground;
      property SliderOptions : CSliderOptions read FOptions write SetOptions;
      property Indicator : CSliderIndicator read FIndic write SetIndicator;
      property IndicatorColor : CSliderIndicatorColor read FIndicColor write SetIndicColor;

      property State : CSliderState read FState write SetState;

      property Max : integer read FMax write SetMax;
      property Min : integer read FMin write SetMin;
      property Position : integer read FPosition write SetPosition;

      property &&&Author: string Read FAuthor;
      property &&&Site: string Read FSite;
      property &&&Version: string Read FVersion;
    public
      procedure Invalidate; override;
  end;

implementation

{ CSliderColors }


{ CSlider }

procedure CSlider.ApplyAccentColor;
var
  AccColor: TColor;
begin
  if FAccent = CAccentColor.None then
    Exit;

  AccColor := GetAccentColor(FAccent);

  FForeground.Leave := AccColor;
  FForeground.Enter := ChangeColorSat(AccColor, 25);
  FForeground.Down := ChangeColorSat(AccColor, -25);
end;

procedure CSlider.CMMouseEnter(var Message: TMessage);
begin
  SetState(cssEnter);
end;

procedure CSlider.CMMouseLeave(var Message: TMessage);
begin
  SetState(cssLeave);
end;

constructor CSlider.Create(AOwner: TComponent);
begin
  inherited;
  FAuthor                       := 'Petculescu Codrut';
  FSite                         := 'https://www.codrutsoftware.cf';
  FVersion                      := '1.4';

  interceptmouse:=True;

  ParentColor := true;
  ParentBackground := true;

  FOptions := CSliderOptions.Create(Self);
  with FOptions do begin
    FRoundness := 5;
    FHeight := 10;
    FWidthMargin := 10;
  end;

  FIndic := CSliderIndicator.Create(Self);
  with FIndic do begin
    FHeight := 15;
    FWidth := 15;
    FRoundness := 50;
    FEnabled := true;

  end;

  FIndicColor := CSliderIndicatorColor.Create(Self);
  with FIndicColor do begin
    FLeave := $00FF8000;
    FEnter := $00FF8000;
    FDown := $00FF8000;
    FMultiColor := true;

    FBorder := $00463E39;
    FBorderThick := 5;

    FDynBorderThick := 3;
    FDynamicBorder := true;
  end;

  FForeground := CSliderForeground.Create(Self);
  with FForeground do begin
    FEnter := $00D7821A;
    FLeave := $00C57517;
    FDown := $008E5611;
    FMultiColor := false;

    FBorder := clGray;
    FBorderThick := 0;
  end;

  FBackground := CSliderBackground.Create(Self);
  with Background do begin
    FEnter := $00D8D8D8;
    FLeave := $00D8D8D8;
    FDown := clGray;
    FMultiColor := false;

    FBorder := clGray;
    FBorderThick := 0;
  end;


  FPreset := CSliderPreset.cslNone;

  FAccent := CAccentColor.AccentAdjust;
  ApplyAccentColor;

  Width := 250;
  Height := 30;

  FPosition := 50;
  FMin := 0;
  FMax := 100;
end;

destructor CSlider.Destroy;
begin
  FreeAndNil(FOptions);
  FreeAndNil(FIndic);
  FreeAndNil(FIndicColor);
  FreeAndNil(FForeground);
  FreeAndNil(FBackground);
  inherited;
end;

procedure CSlider.Invalidate;
begin
  inherited;

  ApplyAccentColor;
end;

procedure CSlider.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: integer);
begin
  inherited;

  SetState(cssDown);
end;

procedure CSlider.MouseMove(Shift: TShiftState; X, Y: integer);
var
  BRect: TRect;
begin
  inherited;

  if FState = cssDown then
    begin
      BRect := Rect(FOptions.FWidthMargin, Height div 2 - FOptions.FHeight div 2,
                    Width - FOptions.WidthMargin, Height div 2 + FOptions.FHeight div 2);

      Position := round( (X - BRect.Left) / (BRect.Width - FOptions.WidthMargin) * (FMax - FMin) ) + FMin;

      if Assigned(FOnChange) then
        FOnChange(Self, Position, FMax, FMin);
    end;
end;

procedure CSlider.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: integer);
begin
  inherited;

  SetState(cssEnter);
end;

procedure CSlider.Paint;
var
  workon: TBitMap;
  BRect, FRect, IRect: TRect;
begin
  inherited;
  ApplyAccentColor;

  SetPresets(FPreset);
  workon := TBitMap.Create;
  try
    workon.Height := Height;
    workon.Width := Width;
    with workon.Canvas do begin
      // Set Rects
      Brush.Color := TStyleManager.ActiveStyle.GetSystemColor(Self.Color);
      FillRect(ClipRect);

      BRect := Rect(FOptions.FWidthMargin, Height div 2 - FOptions.FHeight div 2,
                    Width - FOptions.WidthMargin, Height div 2 + FOptions.FHeight div 2);

      FRect := BRect;
      FRect.Width := trunc((FPosition - FMin) / (FMax - FMin) * BRect.Width);

      IRect.Top := BRect.CenterPoint.Y - FIndic.FHeight div 2;
      IRect.Left := FRect.Right - FIndic.FWidth div 2;
      IRect.Width := FIndic.FWidth;
      IRect.Height := FIndic.FHeight;

      // Draw Background
      if NOT FBackground.FMultiColor then
        Brush.Color := FBackground.FLeave
         else
          with Brush do
            case FState of
              cssLeave: Color := FBackground.FLeave;
              cssEnter: Color := FBackground.FEnter;
              cssDown: Color := FBackground.FDown;
            end;

      Pen.Color := FBackground.FBorder;
      Pen.Width := FBackground.FBorderThick;
      if Pen.Width = 0 then
        Pen.Style := psClear
      else
        Pen.Style := psSolid;

      RoundRect(BRect, FOptions.FRoundness, FOptions.FRoundness);

      // Draw Foreground
      if NOT FForeground.FMultiColor then
        Brush.Color := FForeground.FLeave
         else
          with Brush do
            case FState of
              cssLeave: Color := FForeground.FLeave;
              cssEnter: Color := FForeground.FEnter;
              cssDown: Color := FForeground.FDown;
            end;

      Pen.Color := FForeground.FBorder;
      Pen.Width := FForeground.FBorderThick;
      if Pen.Width = 0 then
        Pen.Style := psClear
      else
        Pen.Style := psSolid;

      RoundRect(FRect, FOptions.FRoundness, FOptions.FRoundness);

      {if FlatEnd then
        begin
          Pen.Style := b
        end;   }

      // Draw Indicator
      if FIndic.FEnabled then
        begin
          // Foreground
          if NOT FIndicColor.FMultiColor then
            Brush.Color := FIndicColor.FLeave
             else
              with Brush do
                case FState of
                  cssLeave: Color := FIndicColor.FLeave;
                  cssEnter: Color := FIndicColor.FEnter;
                  cssDown: Color := FIndicColor.FDown;
                end;

          Pen.Color := FIndicColor.FBorder;
          Pen.Width := FIndicColor.FBorderThick;
          if Pen.Width = 0 then
            Pen.Style := psClear
          else
            Pen.Style := psSolid;

          RoundRect(IRect, FIndic.FRoundness, FIndic.FRoundness);

          { Dynamic Border }
          if FIndicColor.FDynamicBorder and (FState = cssEnter) then
            begin
              Pen.Width := FIndicColor.FDynBorderThick;
              RoundRect(IRect, FIndic.FRoundness, FIndic.FRoundness);
            end;
        end;

    end;
  finally
    Canvas.CopyRect(Rect(0,0,width,height),workon.Canvas,workon.canvas.ClipRect);

    workon.Free;
  end;
end;

procedure CSlider.SetAccentColor(const Value: CAccentColor);
begin
  FAccent := Value;

  if Value <> CAccentColor.None then
    ApplyAccentColor;

  Paint;
end;

procedure CSlider.SetBackground(const Value: CSliderBackground);
begin
  FBackground := Value;

  Paint;
end;

procedure CSlider.SetForeground(const Value: CSliderForeground);
begin
  FForeground := Value;

  Paint;
end;

procedure CSlider.SetIndicator(const Value: CSliderIndicator);
begin
  FIndic := Value;

  Paint;
end;

procedure CSlider.SetIndicColor(const Value: CSliderIndicatorColor);
begin
  FIndicColor := Value;

  Paint;
end;

procedure CSlider.SetMax(const Value: integer);
begin
  FMax := Value;
  if FPosition > FMax then FPosition := FMax;
  Paint;
end;

procedure CSlider.SetMin(const Value: integer);
begin
  FMin := Value;
  if FPosition < FMin then
    FPosition := FMin;
  Paint;
end;

procedure CSlider.SetOptions(const Value: CSliderOptions);
begin
  FOptions := Value;
end;

procedure CSlider.SetPosition(const Value: integer);
begin
  FPosition := Value;

  if csLoading in ComponentState then
    Exit;

  if FPosition > FMax then
    FPosition := FMax;

  if FPosition < FMin then
    FPosition := FMin;

  Paint;
end;

procedure CSlider.SetPresets(const Value: CSliderPreset);
begin
  //if FProgOptions.exceptpreset then Exit;
  FPreset := Value;

end;

procedure CSlider.SetState(const Value: CSliderState);
begin
  FState := Value;

  Paint;
end;

end.
