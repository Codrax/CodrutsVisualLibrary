unit Cod.Visual.ColorBright;

interface

uses
  SysUtils,
  Classes,
  Windows,
  Controls,
  Graphics,
  ExtCtrls,
  Math,
  Styles,
  Forms,
  Cod.Components,
  Cod.Visual.CPSharedLib,
  Themes,
  Types,
  Imaging.pngimage;

type
  CColorBright = class;

  CColorBrightChangeColor = procedure(Sender: CColorBright; Color: TColor; X, Y: integer) of object;

  CColorBright = class(TCustomTransparentControl)
      constructor Create(AOwner : TComponent); override;
      destructor Destroy; override;
    private
      gradient: TBitMap;
      ColorBG: TColor;
      ColorCoord: TPoint;
      FColor, FMainColor: TColor;
      MouseIsDown: boolean;
      FTransparent: Boolean;
      FChangeColor: CColorBrightChangeColor;
      FSyncBgColor: boolean;

      procedure RedrawGradient;
      procedure ChangeColor(color: TColor; x, y: integer);
    procedure SetBGColor(const Value: TColor);
    procedure SetFormSync(const Value: boolean);
    procedure SetColor(const Value: TColor);
    procedure SetTransparent(const Value: boolean);
    procedure SetMainColor(const Value: TColor);
    protected
      procedure Paint; override;
      procedure MouseDown(Button : TMouseButton; Shift: TShiftState; X, Y : integer); override;
      procedure MouseUp(Button : TMouseButton; Shift: TShiftState; X, Y : integer); override;
      procedure MouseMove(Shift: TShiftState; X, Y : integer); override;
      procedure GradHorizontal(Canvas:TCanvas; Rect:TRect; FromColor, ToColor:TColor) ;
      procedure KeyPress(var Key: Char); override;
      procedure DoEnter; override;
      procedure DoExit; override;
    published
      property OnMouseEnter;
      property OnMouseLeave;
      property OnMouseDown;
      property OnMouseUp;
      property OnMouseMove;
      property OnClick;

      property TabStop;
      property TabOrder;

      property Align;
      property Anchors;
      property Cursor;
      property Visible;
      property Enabled;
      property Constraints;
      property DoubleBuffered;
      property ChangeItemColor: CColorBrightChangeColor read FChangeColor write FChangeColor;
      property FormSyncedColor : boolean read FSyncBgColor write SetFormSync;

      property Transparent: boolean read FTransparent write SetTransparent;
      property Color: TColor read FColor write SetColor;
      property PureColor: TColor read FMainColor write SetMainColor;
      property BackGroundColor: TColor read ColorBG write SetBGColor;
    public
      procedure SetFocus(); override;
      procedure ChangeX(x: integer);
  end;

implementation

function CalculateLight(col: TColor): integer;
var
  l1, l2, l3: real;
begin
  l1 := getRvalue(col);
  l2 := getGvalue(col);
  l3 := getBvalue(col);

  Result := trunc((l1 + l2 + l3)/3);
end;


{ CColorBright }

procedure CColorBright.GradHorizontal(Canvas:TCanvas; Rect:TRect; FromColor, ToColor:TColor);
var
   X: integer;
   dr, dg, db:Extended;
   r1, r2, g1, g2, b1, b2:Byte;
   R, G, B:Byte;
   cnt, csize:integer;
begin
  //Unpack Colors
  tocolor := ColorToRGB(tocolor);
  fromcolor := ColorToRGB(fromcolor);

   R1 := GetRValue(FromColor) ;
   G1 := GetGValue(FromColor) ;
   B1 := GetBValue(FromColor) ;

   R2 := GetRValue(ToColor) ;
   G2 := GetGValue(ToColor) ;
   B2 := GetBValue(ToColor) ;

   //Calculate Width
   csize := Rect.Right-Rect.Left;
   if csize <= 0 then Exit;

   //Get Color mdi
   dr := (R2-R1) / csize;
   dg := (G2-G1) / csize;
   db := (B2-B1) / csize;

   if dr < 0 then dr := dr * -1;
   if dg < 0 then dr := dg * -1;
   if db < 0 then dr := db * -1;

   //Start Draw
   cnt := 0;
   for X := Rect.Left to Rect.Right-1 do
   begin
     R := R1+Ceil(dr*cnt) ;
     G := G1+Ceil(dg*cnt) ;
     B := B1+Ceil(db*cnt) ;

     Canvas.Pen.Color := RGB(R,G,B) ;
     Canvas.MoveTo(X,Rect.Top) ;
     Canvas.LineTo(X,Rect.Bottom) ;
     inc(cnt) ;
   end;
end;

procedure CColorBright.KeyPress(var Key: Char);
var
  x: integer;
  nr, v: integer;
begin
  inherited;
  if (key = #37) or (key = '-') or (key = 'a')  then begin
    x := colorcoord.X - 1;
    if (x > 0) and (x < width)then
      MouseDown(mbLeft,[], x, colorcoord.Y);
      MouseUp(mbLeft,[],x,colorcoord.Y);
  end;
  if (key = #39) or (key = '=') or (key = '+') or (key = 'd') then begin
    x := colorcoord.X + 1;
    if (x > 0) and (x < width)then
      MouseDown(mbLeft,[], x, colorcoord.Y);
      MouseUp(mbLeft,[],x,colorcoord.Y);
  end;

  val(char(key), nr, v);

  if key = 'm' then begin nr := 10; v := 0; end;
  

  if (nr >= 0) and (nr <= 10) and (v = 0) then begin
    x := trunc((nr * 10) / 100 * (width - 1));
    if x = 0 then x := 1;
    if (x > 0) and (x <= width)then
      MouseDown(mbLeft,[], x, colorcoord.Y);
      MouseUp(mbLeft,[],x,colorcoord.Y);
  end;
end;

procedure CColorBright.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: integer);
begin
  inherited;
  MouseIsDown := true;
  MouseMove(Shift, X, Y);
end;

procedure CColorBright.MouseMove(Shift: TShiftState; X, Y: integer);
begin
  inherited;
  if (gradient.Height <> self.Height) or (gradient.Width <> self.Width) then RedrawGradient;
  

  if MouseIsDown or (Shift =  [ssShift]) then begin
    if Power((x - width div 2), 2) + Power((y - height div 2), 2) < Power(width div 2, 2) then begin
      ColorCoord.X := X;
      ColorCoord.Y := Y;

      ChangeColor(gradient.Canvas.Pixels[trunc(x), height div 3], x, y);
    end;
    Paint;
  end;
end;

procedure CColorBright.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: integer);
begin
  inherited;
  MouseIsDown := false;
  try
    Self.SetFocus;
  except
  end;
end;

procedure CColorBright.ChangeColor(color: TColor; x, y: integer);
begin
  FColor := color;
  if Assigned(FChangeColor) then FChangeColor(Self, color, x, y);
end;

procedure CColorBright.ChangeX(x: integer);
begin
  MouseMove([ssShift],x, 0);
end;

constructor CColorBright.Create(AOwner: TComponent);
begin
  inherited;
  interceptmouse:=True;

  ColorBG := clWhite;

  FMainColor := clBlue;

  TabStop := true;

  if gradient = nil then RedrawGradient;

  colorcoord := Point(50, 50);

  FTransparent := false;
  FSyncBgColor := true;

  Width := 150;
  Height := 20;

  RedrawGradient;
end;

destructor CColorBright.Destroy;
begin
  FreeAndNil(gradient);
  inherited;
end;


procedure CColorBright.DoEnter;
begin
  inherited;

end;

procedure CColorBright.DoExit;
begin
  inherited;
  Paint;
end;

procedure CColorBright.Paint;
var
  pts: array[1..3] of TPoint;
  sz: integer;
begin
  inherited;

  if (FTransparent) and (NOT gradient.Transparent) then
  begin
    gradient.Transparent := true;
    gradient.TransparentColor := colorbg;
    gradient.TransparentMode := tmAuto;
  end else if gradient.Transparent then gradient.Transparent := false;


  with canvas do begin
    StretchDraw(Rect(0, 0, width, height), gradient);


    Pen.Color := clWhite;
    if self.focused then
      Brush.Color := clWhite
    else
      Brush.Color := clBlack;

    sz := round(self.Height / 3.5);

    pts[1].Y := Height;
    pts[2].Y := Height;
    pts[1].X := ColorCoord.X - sz div 2;
    pts[2].X := pts[1].X + sz;

    pts[3].Y := pts[1].Y - sz;
    pts[3].X := ColorCoord.X;

    canvas.Polygon(pts);

    {Pen.Color := clBlack;
    Pen.Width := 1;
    Brush.Style := bsClear;
    Rectangle(ColorCoord.X - 2, ColorCoord.Y - 2, ColorCoord.X + 2, ColorCoord.Y + 2);         }
  end;
end;

procedure CColorBright.RedrawGradient;
var
  bgc: TColor;
  R1, R2: TRect;
  i: integer;
begin
  if gradient = nil then
    gradient := TBitMap.Create;

  gradient.Width := Width;
  gradient.Height := Height;

  R1 := Rect(0, 0, round(width / 2), height);
  R2 :=  Rect(round(width / 2), 0, width, height);

  gradient.Canvas.Brush.Style := bsSolid;

  GradHorizontal(gradient.Canvas, R1, clBlack, FMainColor);
  GradHorizontal(gradient.Canvas, R2, FMainColor, clWhite);

  bgc := colorbg;

  if FSyncBgColor then
  begin
    if StrInArray(TStyleManager.ActiveStyle.Name, nothemes) then begin
      if GetParentForm(Self) <> nil then
        bgc := GetParentForm(Self).Color;
    end else begin
      bgc := TStyleManager.ActiveStyle.GetSystemColor(clBtnFace);
    end;
  end;

  gradient.Canvas.Pen.Color := bgc;
  gradient.Canvas.Brush.Style := bsClear;

  for I := 1 to self.Height div 4 do
    gradient.Canvas.RoundRect(0,0, width + 1, height, i, i);

  //gradient.Canvas.TextOut(0,0,TStyleManager.ActiveStyle.Name);
end;

procedure CColorBright.SetBGColor(const Value: TColor);
begin
  ColorBG := Value;
  RedrawGradient;
  Paint;
end;

procedure CColorBright.SetColor(const Value: TColor);
var
  I: Integer;
begin
  FColor := Value;

  for I := 0 to width do
    if CalculateLight(Gradient.Canvas.Pixels[trunc(I / width * 500), trunc(height / 10)]) = CalculateLight(FColor) then
    begin
      ColorCoord.X := I;
      Break
    end;

  Paint;
end;

procedure CColorBright.SetFocus;
begin
  inherited;
    Paint;
end;

procedure CColorBright.SetFormSync(const Value: boolean);
begin
  FSyncBgColor := Value;
  RedrawGradient;
  Paint;
end;

procedure CColorBright.SetMainColor(const Value: TColor);
begin
  FMainColor := Value;

  ColorCoord.X := width div 2;

  RedrawGradient;

  FColor := FMainColor;

  ChangeColor(gradient.Canvas.Pixels[width div 2, height div 3], ColorCoord.X, ColorCoord.Y);

  Paint;
end;

procedure CColorBright.SetTransparent(const Value: boolean);
begin
  FTransparent := Value;
end;

end.
