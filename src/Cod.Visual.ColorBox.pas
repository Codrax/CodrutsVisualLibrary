unit Cod.Visual.ColorBox;

interface

uses
  SysUtils,
  Classes,
  Winapi.Windows,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ExtCtrls,
  Cod.Components,
  System.Math,
  Vcl.Styles,
  Vcl.Forms,
  System.Messaging,
  UITypes,
  Cod.Visual.CPSharedLib,
  Vcl.Themes,
  Vcl.Imaging.pngimage;

type
  CColorBox = class;

  CColorBoxPresets = (clpNone, clpFluent, clpMetro, clpWin32);

  CColorBoxPreset = class(TMPersistent)
    private
      FpKind: CColorBoxPresets;
      FrColor: TColor;
    function Paint: Boolean;
    published
      property Color : TColor read FrColor write FrColor stored Paint;
      property Kind : CColorBoxPresets read FpKind write FpKind stored Paint;
  end;

  CColorBox = class(TCustomTransparentControl)
      constructor Create(AOwner : TComponent); override;
      destructor Destroy; override;
    private
      FColor,
      FBorderColor: TColor;
      FRound,
      FInnerRound,
      FThick: integer;
      FPreset: CColorBoxPreset;
      FTransparent: boolean;

      //FFormSync: boolean;

      FAnim: TTimer;
      FAnimTo,
      FAN: integer;

      procedure InitAnim(tovalue: integer);
      procedure AnimExecute(Sender: TObject);
      procedure SetColor(const Value: TColor);
      procedure SetRound(const Value: integer);
      procedure SetThick(const Value: integer);
      procedure SetPenColor(const Value: TColor);
      function ChangeColorSat(clr: TColor; perc: integer): TColor;
      procedure ApplyPreset(const Value: CColorBoxPresets);
      procedure SetInRound(const Value: integer);
    procedure SetTransparent(const Value: boolean);
      protected
      procedure Paint; override;
      procedure MouseDown(Button : TMouseButton; Shift: TShiftState; X, Y : integer); override;
      procedure MouseUp(Button : TMouseButton; Shift: TShiftState; X, Y : integer); override;
      procedure CMMouseEnter(var Message : TMessage); message CM_MOUSEENTER;
      procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
      procedure KeyPress(var Key: Char); override;
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
      property TabStop;
      property TabOrder;

      property ParentColor;
      property Color;

      property Transparent: boolean read FTransparent write SetTransparent;
      //property FormColorSync: boolean read FFormSync write FFormSync;
      property Preset : CColorBoxPreset read FPreset Write FPreset;
      property ItemColor : TColor read FColor write SetColor;
      property PenRound : integer read  FRound write SetRound;
      property PenInnerRound : integer read  FInnerRound write SetInRound;
      property PenThick : integer read  FThick write SetThick;
      property PenColor : TColor read FBorderColor write SetPenColor;
    public
      procedure Invalidate; override;
  end;

implementation

{ CColorBright }

procedure CColorBox.ApplyPreset(const Value: CColorBoxPresets);
begin
  FPreset.Kind := Value;

  if FPreset.Kind = clpNone then Exit;

  FBorderColor := FPreset.FrColor;

  case FPreset.Kind of
    clpFluent: begin
      FRound := 10;
      FInnerRound := 10;
      FThick := 5;
      Height := 40;
      Width := 40;
    end;
    clpWin32: begin
      FRound := 0;
      FInnerRound := 2;
      FThick := 3;
      Height := 30;
      Width := 30;
    end;
    clpMetro: begin
      FRound := 0;
      FInnerRound := 0;
      FThick := 5;
      Height := 40;
      Width := 40;
    end;
  end;
end;

function CColorBox.ChangeColorSat(clr: TColor; perc: integer): TColor;
var
  RBGval: longint;
  R, G, B: integer;
begin
  RBGval := ColorToRGB(clr);
  R := GetRValue(RBGval);
  G := GetGValue(RBGval);
  B := GetBValue(RBGval);

  R := R + perc;
  G := G + perc;
  B := B + perc;

  if R < 0 then R := 0;
  if G < 0 then G := 0;
  if B < 0 then B := 0;

  if R > 255 then R := 255;
  if G > 255 then G := 255;
  if B > 255 then B := 255;

  Result := RGB(r,g,b);
end;

procedure CColorBox.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: integer);
begin
  inherited;
  InitAnim(-30);
end;

procedure CColorBox.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: integer);
begin
  inherited;
  InitAnim(20);
end;


procedure CColorBox.AnimExecute(Sender: TObject);
begin
  if FAN < FAnimTo then inc(FAN, 2);
  if FAN > FAnimTo then dec(FAN, 2);

  if FAN = FAnimTo then FAnim.Enabled := false;

  Paint;
end;

procedure CColorBox.CMMouseEnter(var Message: TMessage);
begin
  InitAnim(20);
end;

procedure CColorBox.CMMouseLeave(var Message: TMessage);
begin
  InitAnim(0);
end;

constructor CColorBox.Create(AOwner: TComponent);
begin
  inherited;
  interceptmouse:=True;

  FPreset := CColorBoxPreset.Create(Self);
  with FPreset do begin
    FpKind := clpNone;
    FrColor := $00313131;
  end;

  TabStop := true;

  FAnim := TTimer.Create(Self);
  with FAnim do begin
    Interval := 1;
    Enabled := false;
    OnTimer := AnimExecute;
  end;

  FAN := 0;

  FTransparent := true;

  FColor := clAqua;
  FThick := 5;
  FRound := 10;
  FInnerRound := 10;
  FBorderColor := $00313131;

  Width := 40;
  Height := 40;
end;

destructor CColorBox.Destroy;
begin
  FreeANdNil(FPreset);
  FAnim.Enabled := false;
  FreeAndNil(FAnim);
  inherited;
end;


procedure CColorBox.InitAnim(tovalue: integer);
begin
  FAnimTo := tovalue;

  FAnim.Interval := 1;

  FAnim.Enabled := true;
end;

procedure CColorBox.Invalidate;
begin
  inherited;

  Paint;
end;

procedure CColorBox.KeyPress(var Key: Char);
begin
  inherited;
  if key = #13 then begin
    FAN := -30;
    Sleep(50);
    if Assigned(OnClick) then OnClick(Self);
    FAN := 0;
    Click;
  end;
end;

procedure CColorBox.Paint;
begin
  inherited;

  ApplyPreset(FPreset.Kind);

  Canvas.Brush.Color := TStyleManager.ActiveStyle.GetSystemColor(Self.Color);

  if NOT FTransparent then
    Canvas.FillRect(canvas.cliprect);

  with inherited canvas do begin
    {Pen.Color := FBorderColor;
    Pen.Width := FThick;
    if FThick = 0 then
      Pen.Style := psClear
    else
      Pen.Style := psSolid;     }

    Pen.Style := psClear;

    Brush.Color := ChangeColorSat(FBorderColor, FAN);

    RoundRect(0, 0, Width, Height, FRound, FRound);

    Brush.Color := FColor;

    RoundRect(FThick, FThick, Width - FThick, Height - FThick, FInnerRound, FInnerRound);
  end;
end;

procedure CColorBox.SetColor(const Value: TColor);
begin
  FColor := Value;
  Paint;
end;

procedure CColorBox.SetInRound(const Value: integer);
begin
  FInnerRound := Value;
  Paint;
end;

procedure CColorBox.SetPenColor(const Value: TColor);
begin
  FBorderColor := Value;
  Paint;
end;

procedure CColorBox.SetRound(const Value: integer);
begin
  FRound := Value;
  Paint;
end;

procedure CColorBox.SetThick(const Value: integer);
begin
  FThick := Value;
  Paint;
end;

procedure CColorBox.SetTransparent(const Value: boolean);
begin
  FTransparent := Value;

  Invalidate;
end;

{ CColorBoxPreset }

function CColorBoxPreset.Paint: Boolean;
begin
  if Self.Owner is CColorBox then begin
    CColorBox(Self.Owner).Paint;
    Result := True;
  end else Result := False;
end;

end.
