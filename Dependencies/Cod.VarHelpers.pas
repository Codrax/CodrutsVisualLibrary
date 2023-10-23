{***********************************************************}
{                  Codruts Variabile Helpers                }
{                                                           }
{                        version 0.2                        }
{                           ALPHA                           }
{                                                           }
{                                                           }
{                                                           }
{                                                           }
{                                                           }
{                   -- WORK IN PROGRESS --                  }
{***********************************************************}

{$SCOPEDENUMS ON}

unit Cod.VarHelpers;

interface
  uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, IdHTTP,
  VCL.Graphics, Winapi.ActiveX, Winapi.URLMon, IOUtils, System.Generics.Collections,
  Cod.ColorUtils, System.Generics.Defaults, Vcl.Imaging.pngimage,
  WinApi.GdipObj, WinApi.GdipApi, Win.Registry, Cod.GDI, Cod.Types,
  DateUtils, Cod.Registry, UITypes;

  type
    // Color Helper
    TColorHelper = record helper for TColor
    public
      function ToString: string; overload; inline;
      function ToInteger: integer; overload; inline;
      function ToRGB: CRGB; overload; inline;
    end;

    // TDateTime Helper
    TDateTimeHelper = record helper for TDateTime
    public
      function ToString: string; overload; inline;
      function ToInteger: integer; overload; inline;

      function Day: integer;
      function Month: integer;
      function Year: integer;

      function Hour: integer;
      function Minute: integer;
      function Second: integer;
      function Millisecond: integer;
    end;

    // TArray colection
    TArrayUtils<T> = class
    public
      class function Contains(const x : T; const anArray : array of T) : boolean;
      class function GetIndex(const x : T; const anArray : array of T) : integer;
    end;

    // TFont
    TAdvFont = type string;

    TAdvFontHelper = record helper for TAdvFont
      function ToString: string;
      procedure FromString(AString: string);
    end;

    // Canvas
    TCanvasHelper = class helper for TCanvas
      procedure DrawHighQuality(ARect: TRect; Bitmap: TBitmap; Opacity: Byte = 255; HighQuality: Boolean = False); overload;
      procedure DrawHighQuality(ARect: TRect; Graphic: TGraphic; Opacity: Byte = 255; HighQuality: Boolean = False); overload;

      procedure StretchDraw(DestRect, SrcRect: TRect; Bitmap: TBitmap; Opacity: Byte); overload;
      procedure StretchDraw(Rect: TRect; Graphic: TGraphic; AOpacity: Byte); overload;

      procedure CopyRect(const Dest: TRect; Canvas: TCanvas; const Source: TRect; Opacity: Byte); overload;

      procedure GDIText(Text: string; Rectangle: TRect; AlignH: TLayout = TLayout.Beginning; AlignV: TLayout = TLayout.Beginning; Angle: integer = 0);
      procedure GDITint(Rectangle: TRect; Color: TColor; Opacity: byte = 75);
      procedure GDIRectangle(Rectangle: TRect; Brush: TGDIBrush; Pen: TGDIPen);
      procedure GDIRoundRect(RoundRect: TRoundRect; Brush: TGDIBrush; Pen: TGDIPen);
      procedure GDICircle(Rectangle: TRect; Brush: TGDIBrush; Pen: TGDIPen);
      procedure GDIPolygon(Points: TArray<TPoint>; Brush: TGDIBrush; Pen: TGDIPen);
      procedure GDILine(Line: TLine; Pen: TGDIPen);
      procedure GDIGraphic(Graphic: TGraphic; Rect: TRect); overload;
      procedure GDIGraphic(Graphic: TGraphic; Rect: TRect; Angle: integer); overload;
      procedure GDIGraphicRound(Graphic: TGraphic; Rect: TRect; Round: real);
    end;

    // Registry
    TRegHelper = Cod.Registry.TRegHelper;

implementation

{ TArrayUtils<T> }

class function TArrayUtils<T>.Contains(const x: T; const anArray: array of T): boolean;
var
  y : T;
  lComparer: IEqualityComparer<T>;
begin
  lComparer := TEqualityComparer<T>.Default;
  for y in anArray do
  begin
    if lComparer.Equals(x, y) then
      Exit(True);
  end;
  Exit(False);
end;

class function TArrayUtils<T>.GetIndex(const x : T; const anArray : array of T) : integer;
var
  I: Integer;
  y: T;
  lComparer: IEqualityComparer<T>;
begin
  lComparer := TEqualityComparer<T>.Default;
  for I := Low(anArray) to High(anArray) do
    begin
      y := anArray[I];

      if lComparer.Equals(x, y) then
        Exit(I);
    end;
    Exit(-1);
end;

// Color
function TColorHelper.ToString: string;
begin
  Result := colortostring( Self );
end;

function TColorHelper.ToInteger: integer;
begin
  Result := ColorToRgb( Self );
end;

function TColorHelper.ToRGB: CRGB;
begin
  Result := GetRGB( Self );
end;

// Date Time
function TDateTimeHelper.ToString: string;
begin
  Result := DateTimeToStr( Self );
end;

function TDateTimeHelper.ToInteger: integer;
begin
  Result := DateTimeToUnix(Self);
end;

function TDateTimeHelper.Day: integer;
begin
  Result := DayOf( Self );
end;

function TDateTimeHelper.Month: integer;
begin
  Result := MonthOf( Self );
end;

function TDateTimeHelper.Year: integer;
begin
  Result := YearOf( Self );
end;

function TDateTimeHelper.Hour: integer;
begin
  Result := HourOf( Self );
end;

function TDateTimeHelper.Minute: integer;
begin
  Result := MinuteOf( Self );
end;

function TDateTimeHelper.Second: integer;
begin
  Result := SecondOf( Self );
end;

function TDateTimeHelper.Millisecond: integer;
begin
  Result := MillisecondOf( Self );
end;

// TFont
function TAdvFontHelper.ToString: string;
begin

end;

procedure TAdvFontHelper.FromString(AString: string);
begin
  //TFont(Self).
end;

{ TCanvasHelper }
procedure TCanvasHelper.DrawHighQuality(ARect: TRect; Bitmap: TBitmap; Opacity: Byte = 255; HighQuality: Boolean = False);
begin
  DrawGraphicHighQuality(Self, ARect, Bitmap, Opacity, HighQuality);
end;

procedure TCanvasHelper.DrawHighQuality(ARect: TRect; Graphic: TGraphic; Opacity: Byte = 255; HighQuality: Boolean = False);
begin
  DrawGraphicHighQuality(Self, ARect, Graphic, Opacity, HighQuality);
end;

procedure TCanvasHelper.StretchDraw(DestRect, SrcRect: TRect; Bitmap: TBitmap; Opacity: Byte);
begin
  GraphicStretchDraw( Self, DestRect, SrcRect, BitMap, Opacity);
end;

procedure TCanvasHelper.StretchDraw(Rect: TRect; Graphic: TGraphic; AOpacity: Byte);
begin
  GraphicStretchDraw(Self, Rect, Graphic, AOpacity);
end;

procedure TCanvasHelper.CopyRect(const Dest: TRect; Canvas: TCanvas; const Source: TRect; Opacity: Byte);
var
  BlendFunction: TBlendFunction;
begin
  // Set up the blending parameters
  BlendFunction.BlendOp := AC_SRC_OVER;
  BlendFunction.BlendFlags := 0;
  BlendFunction.SourceConstantAlpha := Opacity;
  BlendFunction.AlphaFormat := AC_SRC_OVER;

  // Perform the alpha blending
  AlphaBlend(
    Self.Handle, Dest.Left, Dest.Top, Dest.Width, Dest.Height,
    Canvas.Handle, Source.Left, Source.Top, Source.Width, Source.Height,
    BlendFunction
  );
end;

procedure TCanvasHelper.GDIText(Text: string; Rectangle: TRect; AlignH,
  AlignV: TLayout; Angle: integer);
var
  AFont: TGPFont;
  AFormat: TGPStringFormat;
  FontStyle: integer;
begin
  // Font Style
  FontStyle := 0;
  if fsBold in Font.Style then
    FontStyle := FontStyle or FontStyleBold;
  if fsItalic in Font.Style then
    FontStyle := FontStyle or FontStyleItalic;
  if fsUnderline in Font.Style then
    FontStyle := FontStyle or FontStyleUnderline;
  if fsStrikeOut in Font.Style then
    FontStyle := FontStyle or FontStyleStrikeout;

  // Font
  AFont := TGPFont.Create(Font.Name, Font.Size, FontStyle, UnitPixel);
  AFormat:= TGPStringFormat.Create;
  try
    AFormat.SetAlignment(StringAlignment(integer(AlignH)));
    AFormat.SetLineAlignment(StringAlignment(integer(AlignV)));

    // Draw
    DrawText(Self, Text, Rectangle, AFont, AFormat, GetRGB(Font.Color).MakeGDIBrush, Angle);
  finally
    AFont.Free;
    AFormat.Free;
  end;
end;

procedure TCanvasHelper.GDITint(Rectangle: TRect; Color: TColor; Opacity: byte = 75);
begin
  TintPicture(Self, Rectangle, Color, Opacity);
end;

procedure TCanvasHelper.GDIRectangle(Rectangle: TRect; Brush: TGDIBrush; Pen: TGDIPen);
begin
  DrawRectangle(Self, Rectangle, Brush, Pen);
end;

procedure TCanvasHelper.GDIRoundRect(RoundRect: TRoundRect; Brush: TGDIBrush; Pen: TGDIPen);
begin
  DrawRoundRect(Self, RoundRect, Brush, Pen);
end;

procedure TCanvasHelper.GDICircle(Rectangle: TRect; Brush: TGDIBrush; Pen: TGDIPen);
begin
  DrawCircle(Self, Rectangle, Brush, Pen);
end;

procedure TCanvasHelper.GDIPolygon(Points: TArray<TPoint>; Brush: TGDIBrush; Pen: TGDIPen);
begin
  DrawPolygon(Self, Points, Brush, Pen);
end;

procedure TCanvasHelper.GDILine(Line: TLine; Pen: TGDIPen);
begin
  DrawLine(Self, Line, Pen);
end;

procedure TCanvasHelper.GDIGraphic(Graphic: TGraphic; Rect: TRect);
begin
  DrawGraphic(Self, Graphic, Rect, 0);
end;

procedure TCanvasHelper.GDIGraphic(Graphic: TGraphic; Rect: TRect; Angle: integer);
begin
  DrawGraphic(Self, Graphic, Rect, Angle);
end;

procedure TCanvasHelper.GDIGraphicRound(Graphic: TGraphic; Rect: TRect; Round: real);
begin
  DrawGraphicRound(Self, Graphic, Rect, Round);
end;

end.