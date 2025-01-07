{***********************************************************}
{                   Codruts Graphics Lib                    }
{                                                           }
{                        version 0.1                        }
{                           ALPHA                           }
{                                                           }
{                                                           }
{                                                           }
{                                                           }
{                                                           }
{                   -- WORK IN PROGRESS --                  }
{***********************************************************}

{$SCOPEDENUMS ON}

unit Cod.Graphics;

interface
uses
  Winapi.Windows, Winapi.Messages, Classes, Vcl.Graphics, System.Types, System.Math,
  Vcl.Forms, System.SysUtils, Vcl.Imaging.pngimage, Vcl.Imaging.GIFImg,
  Vcl.Imaging.jpeg, Cod.ColorUtils, Cod.VarHelpers, Cod.Types,
  Cod.StringUtils, Cod.GDI, Cod.ArrayHelpers, Contnrs;

type
  // Blur Function Dependencies
  TKernelSize = 1..50;
  TKernel = record
    Size: TKernelSize;
    Weights: array[-50..50] of Single;
  end;
  TRGBTriple = packed record
    b: Byte; {easier to type than rgbtBlue}
    g: Byte;
    r: Byte;
  end;
  PRow = ^TRow;
  TRow = array[Word] of TRGBTriple;
  PPRows = ^TPRows;
  TPRows = array[Word] of PRow;

  // Png Components 2009
  {$SCOPEDENUMS OFF}
  TPngOption = (pngBlendOnDisabled, pngGrayscaleOnDisabled);
  TPngOptions = set of TPngOption;
  {$SCOPEDENUMS ON}

  // Items
  TPent = array[0..4] of TPoint;
  TDrawMode = (Fill, Fit, Stretch, Center, CenterFill, Center3Fill,
    CenterFit, Normal, Tile); { Windows DWM use a Center3 Fill }

  TTextFlag = (WordWrap, Top, VerticalCenter, Bottom, Left, Center, Right,
    NoClip, ShowAccelChar, Ellipsis, Auto);
  TTextFlags= set of TTextFlag;

{ Text }
function GetMaxFontSize(Canvas: TCanvas; Text: string; MaxWidth,
  MaxHeight: Integer): integer;
function GetMaxFontHeight(Canvas: TCanvas; Text: string; ARect: TRect): integer; overload;
function GetMaxFontHeight(Canvas: TCanvas; Text: string; MaxWidth,
  MaxHeight: Integer): integer; overload;
(* Font.Height gives a better precision on font size than Font.Size *)
function TrimmifyText(Canvas: TCanvas; Text: string; MaxWidth: Integer;
  AddDots: boolean = true): string;
function CalcTextWidth(Text: string; Font: TFont): integer; overload;
function CalcTextWidth(Text: string; FontName: string;
  FontSize: integer): integer; overload;
procedure DrawTextRect(Canvas: TCanvas; ARect: TRect; Text: string;
  Flags: TTextFlags; AMargin: integer = 0);
function GetTextRect(Canvas: TCanvas; ARect: TRect; Text: string;
  Flags: TTextFlags; AMargin: integer = 0): TRect;
function GetWordWrapLines(Canvas: TCanvas; Text: string;
  ARect: TRect): TArray<string>;
function WordWrapGetLineHeight(Canvas: TCanvas; Text: string): integer;

(* Draws inverted colored text *)
procedure DrawInvertedText(const ACanvas: TCanvas; const Text: string; const X, Y: integer);

{ Lines }
procedure DrawLine(Canvas: TCanvas; ALine: TLine);
procedure DrawLineOnPoint(Canvas: TCanvas; APoint: TPoint; AAngle: real;
  ALength: integer);

{ Round Rect }
procedure DrawRoundRect(Canvas: TCanvas; RndRect: TRoundRect);
procedure CopyRoundRect(FromCanvas: TCanvas; FromRect: TRoundRect;
                        DestCanvas: TCanvas; DestRect: TRect; shrinkborder: integer = 0);

{ Bitmaps }
procedure GradHorizontal(Canvas:TCanvas; Rect:TRect; FromColor, ToColor:TColor);
procedure GradVertical(Canvas:TCanvas; Rect:TRect; FromColor, ToColor:TColor);
function CanvasToBitmap(Canvas: TCanvas): TBitMap;
function RemoveColor(imgsrc: TBitMap; color: TColor): TBitMap;

{ Drawing }
function DrawModeToImageLayout(DrawMode: TDrawMode): TRectLayout;
procedure DrawImageInRect(Canvas: TCanvas; Rect: TRect; Image: TGraphic;
  Layout: TRectLayout; ClipImage: boolean = false; Opacity: byte = 255); overload;
procedure DrawImageInRect(Canvas: TCanvas; Rect: TRect; Image: TGraphic;
  DrawMode: TDrawMode = TDrawMode.Fill; ImageMargin: integer = 0;
  ClipImage: boolean = false; Opacity: byte = 255); overload;

{ Interesting draw }
procedure DrawFlowersOfLife(Canvas: TCanvas; Rect: TRect; FlowerSize: integer);

{ Inversion Draw }
procedure StretchInvertedMask(Source: TBitMap; Destination: TCanvas; DestRect: TRect); overload;
procedure StretchInvertedMask(Source: TCanvas; Destination: TCanvas; DestRect: TRect); overload;

{ Canvas Utils }
procedure CopyRectWithOpacity(Dest: TCanvas; DestRect: TRect; Source: TCanvas; SourceRect: TRect; Opacity: Byte);

{ Screen }
procedure QuickScreenShot(var BitMap: TBitMap; Monitor: integer = -2);
procedure QuickScreenShotEx(var Bild: TBitMap);
procedure ScreenShotApplication(var BitMap: TBitMap; ApplicationCapton: string = 'Program Manager');

{ Graphics }
procedure LoadGraphicFromFile(var Graphic: TGraphic; filename: string);
function ResizeGraphic(AGraphic: TGraphic; AWidth, AHeight: integer): TBitMap;

procedure GaussianBlur(Bitmap: TBitmap; Radius: Real);
procedure FastBlur(Bitmap: TBitmap; Radius: Real; BlurScale: Integer; HighQuality: Boolean = True);
// Blur Functions, credited to ES components pack, also credited to GBlur2

{ Object Draw }
function MakePent(X, Y, L : integer) : TPent;
procedure MakeStar(Canvas : TCanvas; cX, cY, size : integer; Colour : TColor;
  bordersize: integer = 2; bordercolor: TColor =clBlack);
procedure DrawPentacle(Canvas : TCanvas; Pent : TPent);

{ PNG Components 2009 }
procedure MakePNGImageBlended(Image: TPngImage; Amount: Byte = 127);
procedure MakePNGImageGrayscale(Image: TPngImage; Amount: Byte = 255);
procedure DrawPNG(Png: TPngImage; Canvas: TCanvas; const ARect: TRect; const Options: TPngOptions);
procedure ConvertToPNG(Source: TGraphic; Dest: TPngImage);
procedure CreatePNG(Color, Mask: TBitmap; Dest: TPngImage; InverseMask: Boolean = False);
procedure CreatePNGMasked(Bitmap: TBitmap; Mask: TColor; Dest: TPngImage);
procedure SlicePNG(JoinedPNG: TPngImage; Columns, Rows: Integer; out SlicedPNGs: TObjectList);

implementation

function GetMaxFontSize(Canvas: TCanvas; Text: string; MaxWidth, MaxHeight: Integer): integer;
// Font should be set up with desired Name/Style/etc.
var
  Ext: TSize;
begin
  Result := 0;
  if Text = '' then
    Exit;

  Canvas.Font.Size := 10;
  repeat
    Canvas.Font.Size := Canvas.Font.Size + 1;
    Ext := Canvas.TextExtent(Text);
  until ((Ext.cx >= MaxWidth) or (Ext.cy >= MaxHeight));
  repeat
    Canvas.Font.Size := Canvas.Font.Size - 1;
    Ext := Canvas.TextExtent(Text);
  until ((Ext.cx <= MaxWidth) and (Ext.cy <= MaxHeight)) or (Canvas.Font.Size = 1);

  Result := Canvas.Font.Size;
end;

function GetMaxFontHeight(Canvas: TCanvas; Text: string; ARect: TRect): integer;
begin
  Result := GetMaxFontHeight(Canvas, Text, ARect.Width, ARect.Height);
end;

function GetMaxFontHeight(Canvas: TCanvas; Text: string; MaxWidth, MaxHeight: Integer): integer;
var
  Ext: TSize;
begin
  Result := 0;
  if Text = '' then
    Exit;

  Canvas.Font.Height := -10;
  repeat
    Canvas.Font.Height := Canvas.Font.Height - 1;
    Ext := Canvas.TextExtent(Text);
  until ((Ext.cx >= MaxWidth) or (Ext.cy >= MaxHeight));
  repeat
    Canvas.Font.Height := Canvas.Font.Height + 1;
    Ext := Canvas.TextExtent(Text);
  until ((Ext.cx <= MaxWidth) and (Ext.cy <= MaxHeight)) or (Canvas.Font.Height = 1);

  Result := Canvas.Font.Height;
end;

function TrimmifyText(Canvas: TCanvas; Text: string; MaxWidth: Integer; AddDots: boolean): string;
const
  DOTS = '...';
var
  DotWidth: integer;
begin
  with Canvas do
    if TextWidth(Text) > MaxWidth then
      begin
        if AddDots then
          DotWidth := TextWidth(DOTS)
        else
          DotWidth := 0;

        repeat
          Text := Copy(Text, 1, Length(Text) - 1);
        until (TextWidth(Text) + DotWidth <= MaxWidth) or (Length(Text) < 2);

        while Text[High(Text)] = ' ' do
          Text := Copy(Text, 1, Length(Text) - 1);

        if AddDots then
          Result := Text + DOTS;
      end
    else
      Result := Text;
end;

function CalcTextWidth(Text: string; Font: TFont): integer;
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

function CalcTextWidth(Text: string; FontName: string; FontSize: integer): integer; overload;
var
  Font: TFont;
begin
  Font := TFont.Create;
  try
    Font.Name := FontName;
    Font.Size := FontSize;

    Result := CalcTextWidth(Text, Font);
  finally
    Font.Free;
  end;
end;

procedure DrawTextRect(Canvas: TCanvas; ARect: TRect; Text: string; Flags: TTextFlags; AMargin: integer);
var
  TextFormat: TTextFormat;
  Lines: TArray<string>;
  Top, LineHeight, I: integer;
  R: TRect;
begin
  // Margin
  if AMargin <> 0 then
    ARect.Inflate(-AMargin, -AMargin);

  // Ignore
  if Text = '' then
    Exit;

  if TTextFlag.Auto in Flags then
    begin
      if Canvas.TextWidth(Text) > ARect.Width then
        Flags := Flags + [TTextFlag.WordWrap];
    end;

  if TTextFlag.WordWrap in Flags then
    begin
      // Line Settings
      TextFormat := [];
      if TTextFlag.Left in Flags then
        TextFormat := TextFormat + [tfLeft];
      if TTextFlag.Center in Flags then
        TextFormat := TextFormat + [tfCenter];
      if TTextFlag.Right in Flags then
        TextFormat := TextFormat + [tfRight];
      if TTextFlag.NoClip in Flags then
        TextFormat := TextFormat + [tfNoClip];
      if TTextFlag.Ellipsis in Flags then
        TextFormat := TextFormat + [tfEndEllipsis];
      if not (TTextFlag.ShowAccelChar in Flags) then
        TextFormat := TextFormat + [tfNoPrefix];

      Lines := GetWordWrapLines(Canvas, Text, ARect);

      // Vertical Align
      Top := 0;
      if TTextFlag.VerticalCenter in Flags then
        begin
          for I := 0 to High(Lines) do
            Top := Top + Canvas.TextHeight(Lines[I]);

          Top := round( ARect.Height / 2 - Top / 2 );
        end;
      if TTextFlag.Bottom in Flags then
        begin
          for I := 0 to High(Lines) do
            Top := Top + Canvas.TextHeight(Lines[I]);

          Top := ARect.Height - Top;
        end;

      Top := Top + ARect.Top;

      // Draw
      for I := 0 to High(Lines) do
        begin
          LineHeight := WordWrapGetLineHeight(Canvas, Lines[I]);

          R := Rect( ARect.Left, Top, ARect.Right, Top + LineHeight );

          Canvas.TextRect( R, Lines[I], TextFormat );

          Top := Top + LineHeight;
        end;
    end
  else
    begin
      TextFormat := [tfSingleLine];
      if TTextFlag.Center in Flags then
        TextFormat := TextFormat + [tfCenter];
      if TTextFlag.Right in Flags then
        TextFormat := TextFormat + [tfRight];
      if TTextFlag.VerticalCenter in Flags then
        TextFormat := TextFormat + [tfVerticalCenter];
      if TTextFlag.Bottom in Flags then
        TextFormat := TextFormat + [tfBottom];
      if TTextFlag.NoClip in Flags then
        TextFormat := TextFormat + [tfNoClip];
      if TTextFlag.Ellipsis in Flags then
        TextFormat := TextFormat + [tfEndEllipsis];
      if not (TTextFlag.ShowAccelChar in Flags) then
        TextFormat := TextFormat + [tfNoPrefix];

      Canvas.TextRect(ARect, Text, TextFormat);
    end;
end;

function GetTextRect(Canvas: TCanvas; ARect: TRect; Text: string;
    Flags: TTextFlags; AMargin: integer = 0): TRect;
var
  TextFormat: TTextFormat;
  Lines: TArray<string>;
  Top, LineHeight, I: integer;
begin
  // Margin
  if AMargin <> 0 then
    ARect.Inflate(-AMargin, -AMargin);

  // Ignore
  if Text = '' then
    Exit;

  if TTextFlag.Auto in Flags then
    begin
      if Canvas.TextWidth(Text) > ARect.Width then
        Flags := Flags + [TTextFlag.WordWrap];
    end;

  if TTextFlag.WordWrap in Flags then
    begin
      // Line Settings
      TextFormat := [];
      if TTextFlag.Left in Flags then
        TextFormat := TextFormat + [tfLeft];
      if TTextFlag.Center in Flags then
        TextFormat := TextFormat + [tfCenter];
      if TTextFlag.Right in Flags then
        TextFormat := TextFormat + [tfRight];
      if TTextFlag.NoClip in Flags then
        TextFormat := TextFormat + [tfNoClip];
      if TTextFlag.Ellipsis in Flags then
        TextFormat := TextFormat + [tfEndEllipsis];
      if not (TTextFlag.ShowAccelChar in Flags) then
        TextFormat := TextFormat + [tfNoPrefix];

      // Lines
      Lines := GetWordWrapLines(Canvas, Text, ARect);

      // Vertical Align
      Top := 0;
      if TTextFlag.VerticalCenter in Flags then
        begin
          for I := 0 to High(Lines) do
            Top := Top + WordWrapGetLineHeight(Canvas, Lines[I]);

          Top := round( ARect.Height / 2 - Top / 2 );
        end;
      if TTextFlag.Bottom in Flags then
        begin
          for I := 0 to High(Lines) do
            Top := Top + WordWrapGetLineHeight(Canvas, Lines[I]);

          Top := ARect.Height - Top;
        end;

      Top := Top + ARect.Top;

      // Result
      Result := ARect;
      Result.Top := Top;

      // Draw
      for I := 0 to High(Lines) do
        begin
          LineHeight := WordWrapGetLineHeight(Canvas, Lines[I]);

          Top := Top + LineHeight;
        end;

      // Result
      Result.Bottom := Top;
    end
  else
    begin
      Result := ARect;
    end;
end;

function GetWordWrapLines(Canvas: TCanvas; Text: string; ARect: TRect): TArray<string>;
var
  Temp: string;
  Words: TArray<string>;
  Line, WordWidth, LineWidth: integer;
  I, Index: Integer;
procedure AddLine;
begin
  Inc(Line);
  SetLength(Result, Line + 1);

  LineWidth := 0;
end;
begin
  // Replace WIN CL format
  Text := Text.Replace(#$A#$D, #13);
  Text := Text.Replace(#$A, #13);

  // Get Words
  Words := GetAllSeparatorItems(Text, [' ']);
  for I := 0 to High(Words)-1 do
    Words[I] := Words[I] + ' ';

  // Split values with #13
  I := 0;
  while I < Length(Words) do
    begin
      Index := Words[I].IndexOf(#13);

      if Index <> -1 then
        begin
          if Index = 0 then
            Index := 1;

          Temp := Words[I].Remove(0, Index);
          TArrayUtils<string>.Insert(I+1, Temp, Words);

          Words[I] := Words[I].Remove(Index, Words[I].Length-Index);
        end;

      Inc(I);
    end;

  // Data
  Line := 0;
  LineWidth := 0;

  // Result
  SetLength(Result, 1);

  // Step
  for I := 0 to High(Words) do
    begin
      // Word
      Temp := Words[I];

      if Temp = #13 then
        begin
          AddLine;
          Continue;
        end;

      // Width
      WordWidth := Canvas.TextWidth(Temp);

      // New Line
      if LineWidth + WordWidth > ARect.Width then
        AddLine;

      // Add to line
      Result[Line] := ConCat(Result[Line], Temp);

      // Add
      LineWidth := LineWidth + WordWidth;
    end;
end;

function WordWrapGetLineHeight(Canvas: TCanvas; Text: string): integer;
begin
  Result := Canvas.TextHeight(Text);
  if Result = 0 then
    Result := Canvas.TextHeight('|');
end;

procedure DrawInvertedText(const ACanvas: TCanvas; const Text: string; const X, Y: integer);
begin
  with TBitmap.Create do
    try
      Canvas.Font.Assign(ACanvas.Font);
      with Canvas.TextExtent(Text) do
        SetSize(cx, cy);
      Canvas.Brush.Color := clBlack;
      Canvas.FillRect(Rect(0, 0, Width, Height));
      Canvas.Font.Color := clWhite;
      Canvas.TextOut(0, 0, Text);
      BitBlt(ACanvas.Handle, X, Y, Width, Height, Canvas.Handle, 0, 0, SRCINVERT);
    finally
      Free;
    end;
end;

procedure DrawLine(Canvas: TCanvas; ALine: TLine);
begin
  with Canvas do begin
    MoveTo(ALine.Point1.X, ALine.Point1.Y);
    LineTo(ALine.Point2.X, ALine.Point2.Y);
  end;
end;

procedure DrawLineOnPoint(Canvas: TCanvas; APoint: TPoint; AAngle: real; ALength: integer);
var
  Line: TLine;
begin
  Line.Point1 := PointAroundCenter(APoint, AAngle + 90, ALength div 2);

  Line.Point2 := PointAroundCenter(APoint, AAngle - 90, ALength div 2);

  DrawLine(Canvas, Line);
end;

procedure DrawRoundRect(Canvas: TCanvas; RndRect: TRoundRect);
var
  x, y, A, m: integer;
  L, B, R, T: TLine;
  Al: Real;
begin
  // Adjust Sizing
  if RndRect.GetRoundness > RndRect.Rect.Height then
    RndRect.SetRoundness( RndRect.Rect.Height );

  m := 1;
  if (RndRect.Rect.Height > m) then
    m := RndRect.Rect.Height;
  if (RndRect.Rect.Width > m) then
    m := RndRect.Rect.Width;

  if m > 90 then
    m := round(m/90) + 1;

  // Draw Curves
  with Canvas do begin
    for A := 90 * m to 180 * m do
      begin
        Al := A / m;
        X := RndRect.Rect.TopLeft.X + RndRect.RoundX div 2;
        Y := RndRect.Rect.TopLeft.Y + RndRect.RoundY div 2;

        X := X + trunc( RndRect.RoundX / 2 * cos(Al*pi/180) );
        Y := Y - trunc( RndRect.RoundY / 2 * sin(Al*pi/180) );

        MoveTo(X, Y);
        LineTo(X, Y);

        if trunc(Al) = 90 then
          T.Point1 := Point(X, Y);
        if trunc(Al) = 180 then
          L.Point1 := Point(X, Y);
      end;
      for A := 180 * m to 270 * m do
      begin
        Al := A / m;
        X := RndRect.Rect.TopLeft.X + RndRect.RoundX div 2;
        Y := RndRect.Rect.BottomRight.Y - RndRect.RoundY div 2;

        X := X + trunc( RndRect.RoundX / 2 * cos(Al*pi/180) );
        Y := Y - trunc( RndRect.RoundY / 2 * sin(Al*pi/180) );

        MoveTo(X, Y);
        LineTo(X, Y);

        if trunc(Al) = 180 then
          L.Point2 := Point(X, Y);
        if trunc(Al) = 270 then
          B.Point1 := Point(X, Y);
      end;
      for A := 270 * m to 360 * m do
      begin
        Al := A / m;
        X := RndRect.Rect.BottomRight.X - RndRect.RoundX div 2;
        Y := RndRect.Rect.BottomRight.Y - RndRect.RoundY div 2;

        X := X + trunc( RndRect.RoundX / 2 * cos(Al*pi/180) );
        Y := Y - trunc( RndRect.RoundY / 2 * sin(Al*pi/180) );

        MoveTo(X, Y);
        LineTo(X, Y);

        if trunc(Al) = 270 then
          B.Point2 := Point(X, Y);
        if trunc(Al) = 360 then
          R.Point1 := Point(X, Y);
      end;
      for A := 0 * m to 90 * m do
      begin
        Al := A / m;
        X := RndRect.Rect.BottomRight.X - RndRect.RoundX div 2;
        Y := RndRect.Rect.TopLeft.Y + RndRect.RoundY div 2;

        X := X + trunc( RndRect.RoundX / 2 * cos(Al*pi/180) );
        Y := Y - trunc( RndRect.RoundY / 2 * sin(Al*pi/180) );

        MoveTo(X, Y);
        LineTo(X, Y);

        if trunc(Al) = 0 then
          R.Point2 := Point(X, Y);
        if trunc(Al) = 90 then
          T.Point2 := Point(X, Y);
      end;

      // Draw Lines
      DrawLine(Canvas, L);
      DrawLine(Canvas, B);
      DrawLine(Canvas, R);
      DrawLine(Canvas, T);
  end;
end;

procedure CopyRoundRect(FromCanvas: TCanvas; FromRect: TRoundRect; DestCanvas: TCanvas; DestRect: TRect; shrinkborder: integer);
var
  x, y, A, m: integer;
  Al: Real;
  HS, HD: TLine;
  S, D: TRect;
begin
  // Border Shrink
  if shrinkborder <> 0 then
  begin
    inc(FromRect.Rect.Left, shrinkborder);
    inc(FromRect.Rect.Top, shrinkborder);
    dec(FromRect.Rect.Right, shrinkborder);
    dec(FromRect.Rect.Bottom, shrinkborder);

    inc(DestRect.Left, shrinkborder);
    inc(DestRect.Top, shrinkborder);
    dec(DestRect.Right, shrinkborder);
    dec(DestRect.Bottom, shrinkborder);
  end;

  // Adjust Sizing
  if FromRect.GetRoundness > FromRect.Rect.Height then
    FromRect.SetRoundness( FromRect.Rect.Height );

  m := 0;
  if (FromRect.Rect.Height > m) then
    m := FromRect.Rect.Height;
  if (FromRect.Rect.Width > m) then
    m := FromRect.Rect.Width;
  if (DestRect.Width > m) then
    m := DestRect.Width;
  if (DestRect.Width > m) then
    m := DestRect.Width;

  if (m = 0) or (FromRect.Width = 0) or (FromRect.Height = 0) then
    Exit;

  if m > 90 then
    m := round(m/90) + 1
  else
    m := 1;


  // Start Copy
    for A := 90 * m to 180 * m do
      begin
        Al := A / m;
        X := round( FromRect.RoundX / 2 * cos(Al*pi/180) );
        Y := round( FromRect.RoundY / 2 * sin(Al*pi/180) );

        S.Left := FromRect.Rect.Left + FromRect.RoundX div 2 + X - 1;
        S.Top := FromRect.Rect.Top + FromRect.RoundY div 2 - Y - 1;

        if S.Bottom > FromRect.Bottom + 1 then
          S.Bottom := FromRect.Bottom + 1;

        S.Right := FromRect.Rect.Right - FromRect.RoundX div 2 - X + 1;
        S.Bottom := FromRect.Rect.Top + FromRect.RoundY div 2 - Y + 1;

        D.Left := DestRect.Left + round( (S.Left - FromRect.Rect.Left) / FromRect.Rect.Width
                                   * DestRect.Width );
        D.Right := DestRect.Left + round( (S.Right - FromRect.Rect.Left) / FromRect.Rect.Width
                                   * DestRect.Width );
        D.Top := DestRect.Top + round( (S.Top - FromRect.Rect.Top) / FromRect.Rect.Height
                                   * DestRect.Height );
        D.Bottom := DestRect.Top + round( (S.Bottom - FromRect.Rect.Top) / FromRect.Rect.Height
                                   * DestRect.Height );

        DestCanvas.CopyRect(D, FromCanvas, S);

        if A = 180 * m then
          begin
            HS.Point1 := S.TopLeft;
            HD.Point1 := D.TopLeft;
          end;
      end;
      for A := 180 * m to 270 * m do
      begin
        Al := A / m;
        X := round( FromRect.RoundX / 2 * cos(Al*pi/180) );
        Y := round( FromRect.RoundY / 2 * sin(Al*pi/180) );

        S.Left := FromRect.Rect.Left + FromRect.RoundX div 2 + X - 1;
        S.Top := FromRect.Rect.Bottom - FromRect.RoundY div 2 - Y - 1;

        S.Right := FromRect.Rect.Right - FromRect.RoundX div 2 - X + 1;
        S.Bottom := FromRect.Rect.Bottom - FromRect.RoundY div 2 - Y + 1;

        if S.Bottom > FromRect.Bottom + 1 then
          S.Bottom := FromRect.Bottom + 1;

        D.Left := DestRect.Left + round( (S.Left - FromRect.Rect.Left) / FromRect.Rect.Width
                                   * DestRect.Width );
        D.Right := DestRect.Left + round( (S.Right - FromRect.Rect.Left) / FromRect.Rect.Width
                                   * DestRect.Width );
        D.Top := DestRect.Top + round( (S.Top - FromRect.Rect.Top) / FromRect.Rect.Height
                                   * DestRect.Height );
        D.Bottom := DestRect.Top + round( (S.Bottom - FromRect.Rect.Top) / FromRect.Rect.Height
                                   * DestRect.Height );

        DestCanvas.CopyRect(D, FromCanvas, S);

        if A = 180 * m then
          begin
            HS.Point2 := S.BottomRight;
            HD.Point2 := D.BottomRight;
          end;
      end;

      // Copy Center Rext
      DestCanvas.CopyRect(TRect.Create(HD.Point1, HD.Point2),
                          FromCanvas, TRect.Create(HS.Point1, HS.Point2));
end;

procedure GradHorizontal(Canvas:TCanvas; Rect:TRect; FromColor, ToColor:TColor);
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

   // Calculate Width
   csize := Rect.Right-Rect.Left;
   if csize <= 0 then Exit;

   // Get Color mdi
   dr := (R2-R1) / csize;
   dg := (G2-G1) / csize;
   db := (B2-B1) / csize;

   // Start Draw
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

procedure GradVertical(Canvas:TCanvas; Rect:TRect; FromColor, ToColor:TColor);
var
   Y: integer;
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

   // Calculate Width
   csize := Rect.Bottom-Rect.Top;
   if csize <= 0 then Exit;

   // Get Color mdi
   dr := (R2-R1) / csize;
   dg := (G2-G1) / csize;
   db := (B2-B1) / csize;

   // Start Draw
   cnt := 0;
   for Y := Rect.Top to Rect.Bottom-1 do
   begin
     R := R1+Ceil(dr*cnt) ;
     G := G1+Ceil(dg*cnt) ;
     B := B1+Ceil(db*cnt) ;

     Canvas.Pen.Color := RGB(R,G,B) ;
     Canvas.MoveTo(Rect.Left,Y) ;
     Canvas.LineTo(Rect.Right,Y) ;
     inc(cnt) ;
   end;
end;

function CanvasToBitmap(Canvas: TCanvas): TBitMap;
begin
  // Convert a TCanvas to a useable TBitmap image
  Result := TBitMap.Create(Canvas.ClipRect.Width, Canvas.ClipRect.Height);

  Result.Canvas.CopyRect(result.Canvas.ClipRect,
                          canvas, canvas.ClipRect);
end;

function RemoveColor(imgsrc: TBitMap; color: TColor): TBitMap;
var
  I: Integer;
  j: Integer;
begin
  result := TBitMap.Create;
  with imgsrc do begin
  for I := 0 to imgsrc.Width do
    for J := 0 to imgsrc.Height do
    begin
      if canvas.Pixels[I, J] <> color then
        result.Canvas.Pixels[I, J] := canvas.Pixels[I, J];
    end;
  end;
end;

procedure DrawImageInRect(Canvas: TCanvas; Rect: TRect; Image: TGraphic;
  DrawMode: TDrawMode; ImageMargin: integer; ClipImage: boolean; Opacity: byte);
var
  Layout: TRectLayout;
begin
  Layout := DrawModeToImageLayout(DrawMode);
  Layout.MarginParent := ImageMargin;

  // Data
  DrawImageInRect(Canvas, Rect, Image, Layout, ClipImage, Opacity);
end;

function DrawModeToImageLayout(DrawMode: TDrawMode): TRectLayout;
begin
  Result := TRectLayout.New;

  // Set
  case DrawMode of
    TDrawMode.Fill: Result.ContentFill := TRectLayoutContentFill.Fill;
    TDrawMode.Fit: Result.ContentFill := TRectLayoutContentFill.Fit;
    TDrawMode.Stretch: Result.ContentFill := TRectLayoutContentFill.Stretch;
    TDrawMode.Center: begin
      Result.LayoutHorizontal := TLayout.Center;
      Result.LayoutVertical := TLayout.Center;
    end;
    TDrawMode.CenterFill: begin
      Result.ContentFill := TRectLayoutContentFill.Fill;

      Result.LayoutHorizontal := TLayout.Center;
      Result.LayoutVertical := TLayout.Center;
    end;
    TDrawMode.Center3Fill: begin
      Result.ContentFill := TRectLayoutContentFill.Fill;

      Result.LayoutHorizontal := TLayout.Center;
      Result.LayoutVertical := TLayout.Center;

      Result.CenterDivisor := TSizeF.Create(3, 3);
    end;
    TDrawMode.CenterFit: begin
      Result.ContentFill := TRectLayoutContentFill.Fit;

      Result.LayoutHorizontal := TLayout.Center;
      Result.LayoutVertical := TLayout.Center;
    end;
    TDrawMode.Tile: begin
      Result.Tile := true;
      Result.TileFlags := [TRectLayoutTileFlag.ExtendX, TRectLayoutTileFlag.ExtendY];
    end;
  end;
end;

procedure DrawImageInRect(Canvas: TCanvas; Rect: TRect; Image: TGraphic;
  Layout: TRectLayout; ClipImage: boolean = false; Opacity: byte = 255);
var
  Rects: TArray<TRect>;
  I: integer;
  Bitmap: TBitMap;
  FRect: TRect;
begin
  // Get Rectangles
  Rects := RectangleLayouts(TSize.Create(Image.Width, Image.Height), Rect, Layout);

  if not ClipImage then
    // Standard Draw
    begin
      for I := 0 to High( Rects ) do
        Canvas.StretchDraw( Rects[I], Image, Opacity );
    end
  else
    // Clip Image Drw
    begin
      for I := 0 to High(Rects) do
        begin
          Bitmap := TBitMap.Create(Rect.Width, Rect.Height);
          Bitmap.PixelFormat := pf32bit;
          Bitmap.Transparent := true;

          const PIXEL_BYTE_SIZE = 4;

          // Fill image with
          for var Y := 0 to Bitmap.Height - 1 do
            FillMemory(Bitmap.ScanLine[Y], PIXEL_BYTE_SIZE * Bitmap.Width, 0);

          Bitmap.Canvas.Lock;
          try
            FRect := Rects[I];
            FRect.Offset( -Rect.Left, -Rect.Top );

            Bitmap.Canvas.StretchDraw(FRect, Image, 255); // Full opacity for temp

            // Image has no alpha channel, set A bytes to 255
            if not Image.Transparent then begin
              const RectZone = TRect.Intersect(Bitmap.Canvas.ClipRect, FRect);

              for var Y := RectZone.Top to RectZone.Bottom-1 do begin
                // Line
                const Pos: PByte = Bitmap.ScanLine[Y];

                // Start left
                for var X := RectZone.Left to RectZone.Right-1 do
                  Pos[X * PIXEL_BYTE_SIZE + 3] := 255;
              end;
            end;

            // Draw
            //Canvas.StretchDraw(Rect, BitMap, Opacity)
            Canvas.Draw(Rect.Left, Rect.Top, BitMap, Opacity);
          finally
            Bitmap.Canvas.Unlock;
            BitMap.Free;
          end;
        end;
    end;
end;

procedure DrawFlowersOfLife(Canvas: TCanvas; Rect: TRect; FlowerSize: integer);
var
  Size: TSize;
procedure DrawCircle(X, Y: integer);
begin
  with Canvas do begin
    Ellipse(X-Size.cx div 2, Y-Size.cy div 2, X+Size.cx div 2, Y+Size.cy div 2);
  end;
end;
var
  X, Y: integer;
  Center: TPoint;
  HorSpacer: integer;
  Add: TSize;
begin
  // Sizes
  Size.cx := trunc(Rect.Width / FlowerSize);
  Size.cy := trunc(Rect.Height / FlowerSize);

  HorSpacer := trunc(0.075*Size.cx);

  Add.cx := Size.cx div 2;
  Add.cy := Size.cy div 2;

  Center := Rect.CenterPoint;

  // Draw
  for var I := -(FlowerSize-1) to FlowerSize-1 do begin
    X := Center.X + (Add.cx-HorSpacer) * I;

    if I = 0 then
      Canvas.Pen.Color := clBLue
    else
      Canvas.Pen.Color := 255;

    // Vertical
    for var J := -(FlowerSize-1)+Abs(I div 2) to FlowerSize-1-Abs(I div 2) do begin
      Y := Center.Y + Add.cy * J;

      // Ext
      Inc(Y, Abs(I mod 2)*(Add.cx div 2));

      // Draw
      DrawCircle( X, Y);
    end;
  end;
end;

procedure StretchInvertedMask(Source: TBitMap; Destination: TCanvas; DestRect: TRect);
begin
  StretchInvertedMask(Source.Canvas, Destination, DestRect);
end;

procedure StretchInvertedMask(Source: TCanvas; Destination: TCanvas; DestRect: TRect);
begin
  BitBlt(Destination.Handle, DestRect.Left, DestRect.Top, DestRect.Width, DestRect.Height,
    Source.Handle, 0, 0, SRCINVERT);
end;

procedure CopyRectWithOpacity(Dest: TCanvas; DestRect: TRect; Source: TCanvas; SourceRect: TRect; Opacity: Byte);
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
    Dest.Handle, DestRect.Left, DestRect.Top, DestRect.Width, DestRect.Height,
    Source.Handle, SourceRect.Left, SourceRect.Top, SourceRect.Width, SourceRect.Height,
    BlendFunction
  );
end;

procedure QuickScreenShot(var BitMap: TBitMap; Monitor: integer);
var
  C: TCanvas;
  R: TRect;
begin
  /// PARAMETER VALUES               ///
  ///                                ///
  /// -2 All Monitors (Default)      ///
  ///                                ///
  /// -1 Default Monitor             ///
  ///                                ///
  ///  >= 0 Monitor Index            ///
  ///                                ///

  case Monitor of
    -2: R := Rect(Screen.DesktopRect.Left, Screen.DesktopRect.Top, Screen.DesktopRect.Right, Screen.DesktopRect.Bottom);

    -1: R := Rect(Screen.PrimaryMonitor.BoundsRect.Left, Screen.PrimaryMonitor.BoundsRect.Top,
            Screen.PrimaryMonitor.BoundsRect.Right, Screen.PrimaryMonitor.BoundsRect.Bottom);

    else R := Rect(Screen.Monitors[Monitor].BoundsRect.Left, Screen.Monitors[Monitor].BoundsRect.Top,
            Screen.Monitors[Monitor].BoundsRect.Right, Screen.Monitors[Monitor].BoundsRect.Bottom);
  end;



  BitMap.Width := R.Width;
  BitMap.Height := R.Height;

  C := TCanvas.Create;
  try
    C.Handle := GetDC(0);

    BitMap.Canvas.CopyRect( BitMap.Canvas.ClipRect, C, R );
  finally
    C.Free;
  end;
end;

procedure QuickScreenShotEx(var Bild: TBitMap);
var
  c: TCanvas;
  r: TRect;
begin
  c := TCanvas.Create;
  c.Handle := GetWindowDC(GetDesktopWindow);
  try
    r := Rect(0, 0, Screen.Width, Screen.Height);
    Bild.Width := Screen.Width;
    Bild.Height := Screen.Height;
    Bild.Canvas.CopyRect(r, c, r);
  finally
    ReleaseDC(0, c.Handle);
    c.Free;
  end;
end;

procedure ScreenShotApplication(var BitMap: TBitMap; ApplicationCapton: string);
var
  Handle: HWND;
  R: TRect;
  DC: HDC;
  Old: HGDIOBJ;

begin
  Handle := FindWindow(nil, PWideChar(ApplicationCapton));
  GetWindowRect(Handle, R);

  Bitmap := TBitmap.Create;
  Bitmap.Width := R.Right - R.Left;
  Bitmap.Height := R.Bottom - R.Top;

  DC := GetDC(Handle);
  Old := SelectObject(DC, Bitmap.Canvas.Handle);
  BitBlt(Bitmap.Canvas.Handle, 0, 0, Bitmap.Width, Bitmap.Height, DC, 0, 0, SRCCOPY);
  SelectObject(DC, Old);
  ReleaseDC(Handle, DC);
end;

procedure LoadGraphicFromFile(var Graphic: TGraphic; filename: string);
var
  MS: TMemoryStream;
  ext: string;
begin
  // Decide extension
  ext := Copy(filename, filename.LastIndexOf('.') + 2, filename.Length);

  if ext = 'bmp' then
    Graphic := TBitMap.Create
  else
  if ext = 'png' then
    Graphic := TPngImage.Create
  else
  if (ext = 'jpg') or (ext = 'jpeg') then
    Graphic := TJpegImage.Create
  else
  if ext = 'gif' then
    Graphic := TGifImage.Create
  else
    {Graphic := TGraphic.Create;}Graphic := TBitMap.Create;

  // Create memory stream
  MS := TMemoryStream.Create;

  MS.LoadFromFile(filename);

  // Load into image
  Ms.Seek(0,soFromBeginning);
  Graphic.LoadFromStream(MS);

  MS.free;
end;

function ResizeGraphic(AGraphic: TGraphic; AWidth, AHeight: integer): TBitMap;
begin
  Result := TBitMap.Create(AWidth, AHeight);

  Result.Canvas.StretchDraw(Rect(0, 0, AWidth, AHeight), AGraphic);
end;

function MakePent(X, Y, L : integer) : TPent;
var
  DX1, DY1, DX2, DY2 : integer;
const
  Sin54 = 0.809;
  Cos54 = 0.588;
  Tan72 = 3.078;
begin
  DX1 := trunc(L * Sin54);
  DY1 := trunc(L * Cos54);
  DX2 := L div 2;
  DY2 := trunc(L * Tan72 / 2);
  Result[0] := point(X, Y);
  Result[1] := point(X - DX1, Y + DY1);
  Result[2] := point(X - DX2, Y + DY2);
  Result[3] := point(X + DX2, Y + DY2);
  Result[4] := point(X + DX1, Y + DY1);
end;

procedure DrawPentacle(Canvas : TCanvas; Pent : TPent);
begin
  with Canvas do begin
    MoveTo(Pent[0].X, Pent[0].Y);
    LineTo(Pent[2].X, Pent[2].Y);
    LineTo(Pent[4].X, Pent[4].Y);
    LineTo(Pent[1].X, Pent[1].Y);
    LineTo(Pent[3].X, Pent[3].Y);
    LineTo(Pent[0].X, Pent[0].Y);
  end;
end;

function ColorToTriple(Color: TColor): Winapi.Windows.TRGBTriple;
var
  ColorRGB: Longint;
begin
  ColorRGB := ColorToRGB(Color);
  Result.rgbtBlue := ColorRGB shr 16 and $FF;
  Result.rgbtGreen := ColorRGB shr 8 and $FF;
  Result.rgbtRed := ColorRGB and $FF;
end;

procedure MakePNGImageBlended(Image: TPngImage; Amount: Byte = 127);

  procedure ForceAlphachannel(BitTransparency: Boolean; TransparentColor: TColor);
  var
    Assigner: TBitmap;
    Temp: TPngImage;
    X, Y: Integer;
    Line: Vcl.Imaging.pngimage.PByteArray;
    Current: TColor;
  begin
    //Not all formats of PNG support an alpha-channel (paletted images for example),
    //so with this function, I simply recreate the PNG as being 32-bits, effectivly
    //forcing an alpha-channel on it.
    Temp := TPngImage.Create;
    try
      Assigner := TBitmap.Create;
      try
        Assigner.Width := Image.Width;
        Assigner.Height := Image.Height;
        Temp.Assign(Assigner);
      finally
        Assigner.Free;
      end;
      Temp.CreateAlpha;
      for Y := 0 to Image.Height - 1 do begin
        Line := Temp.AlphaScanline[Y];
        for X := 0 to Image.Width - 1 do begin
          Current := Image.Pixels[X, Y];
          Temp.Pixels[X, Y] := Current;
          if BitTransparency and (Current = TransparentColor) then
            Line[X] := 0
          else
            Line[X] := Amount;
        end;
      end;
      Image.Assign(Temp);
    finally
      Temp.Free;
    end;
  end;

var
  X, Y: Integer;
  Line: Vcl.Imaging.pngimage.PByteArray;
  Forced: Boolean;
  TransparentColor: TColor;
  BitTransparency: Boolean;
begin
  //If the PNG doesn't have an alpha channel, then add one
  BitTransparency := Image.TransparencyMode = ptmBit;
  TransparentColor := Image.TransparentColor;
  Forced := False;
  if not (Image.Header.ColorType in [COLOR_RGBALPHA, COLOR_GRAYSCALEALPHA]) then begin
    Forced := Image.Header.ColorType in [COLOR_GRAYSCALE, COLOR_PALETTE];
    if Forced then
      ForceAlphachannel(BitTransparency, TransparentColor)
    else
      Image.CreateAlpha;
  end;

  //Divide the alpha values by 2
  if not Forced and (Image.Header.ColorType in [COLOR_RGBALPHA, COLOR_GRAYSCALEALPHA]) then begin
    for Y := 0 to Image.Height - 1 do begin
      Line := Image.AlphaScanline[Y];
      for X := 0 to Image.Width - 1 do begin
        if BitTransparency and (Image.Pixels[X, Y] = TransparentColor) then
          Line[X] := 0
        else
          Line[X] := Round(Line[X] / 256 * (Amount + 1));
      end;
    end;
  end;
end;

procedure MakePNGImageGrayscale(Image: TPngImage; Amount: Byte = 255);

  procedure GrayscaleRGB(var R, G, B: Byte);
  { Performance optimized version without floating point operations by Christian Budde }
  var
    X: Byte;
  begin
    X := (R * 77 + G * 150 + B * 29) shr 8;
    R := ((R * (255 - Amount)) + (X * Amount) + 128) shr 8;
    G := ((G * (255 - Amount)) + (X * Amount) + 128) shr 8;
    B := ((B * (255 - Amount)) + (X * Amount) + 128) shr 8;
    (* original code
    X := Round(R * 0.30 + G * 0.59 + B * 0.11);
    R := Round(R / 256 * (256 - Amount - 1)) + Round(X / 256 * (Amount + 1));
    G := Round(G / 256 * (256 - Amount - 1)) + Round(X / 256 * (Amount + 1));
    B := Round(B / 256 * (256 - Amount - 1)) + Round(X / 256 * (Amount + 1));
    *)
  end;

var
  X, Y, PalCount: Integer;
  Line: PRGBLine;
  PaletteHandle: HPalette;
  Palette: array[Byte] of TPaletteEntry;
begin
  //Don't do anything if the image is already a grayscaled one
  if not (Image.Header.ColorType in [COLOR_GRAYSCALE, COLOR_GRAYSCALEALPHA]) then begin
    if Image.Header.ColorType = COLOR_PALETTE then begin
      //Grayscale every palette entry
      PaletteHandle := Image.Palette;
      PalCount := GetPaletteEntries(PaletteHandle, 0, 256, Palette);
      for X := 0 to PalCount - 1 do
        GrayscaleRGB(Palette[X].peRed, Palette[X].peGreen, Palette[X].peBlue);
      SetPaletteEntries(PaletteHandle, 0, PalCount, Palette);
      Image.Palette := PaletteHandle;
    end
    else begin
      //Grayscale every pixel
      for Y := 0 to Image.Height - 1 do begin
        Line := Image.Scanline[Y];
        for X := 0 to Image.Width - 1 do
          GrayscaleRGB(Line[X].rgbtRed, Line[X].rgbtGreen, Line[X].rgbtBlue);
      end;
    end;
  end;
end;

procedure DrawPNG(Png: TPngImage; Canvas: TCanvas; const ARect: TRect; const Options: TPngOptions);
var
  PngCopy: TPngImage;
begin
  if Options <> [] then begin
    PngCopy := TPngImage.Create;
    try
      PngCopy.Assign(Png);
      if pngBlendOnDisabled in Options then
        MakePNGImageBlended(PngCopy);
      if pngGrayscaleOnDisabled in Options then
        MakePNGImageGrayscale(PngCopy);
      PngCopy.Draw(Canvas, ARect);
    finally
      PngCopy.Free;
    end;
  end
  else begin
    Png.Draw(Canvas, ARect);
  end;
end;

procedure ConvertToPNG(Source: TGraphic; Dest: TPngImage);
type
  TRGBALine = array[Word] of TRGBQuad;
  PRGBALine = ^TRGBALine;
var
  MaskLines: array of Vcl.Imaging.pngimage.PByteArray;

  function ColorToTriple(const Color: TColor): Winapi.Windows.TRGBTriple;
  begin
    Result.rgbtBlue := Color shr 16 and $FF;
    Result.rgbtGreen := Color shr 8 and $FF;
    Result.rgbtRed := Color and $FF;
  end;

  procedure GetAlphaMask(SourceColor: TBitmap);
  type
    TBitmapInfoV4 = packed record
      bmiHeader: TBitmapV4Header; //Otherwise I may not get per-pixel alpha values.
      bmiColors: array[0..2] of TRGBQuad; // reserve space for color lookup table
    end;
  var
    Bits: PRGBALine;
    { The BitmapInfo parameter to GetDIBits is delared as var parameter. So instead of casting around, we simply use
      the absolute directive to refer to the same memory area. }
    BitmapInfo: TBitmapInfoV4;
    BitmapInfoFake: TBitmapInfo absolute BitmapInfo;
    I, X, Y: Integer;
    HasAlpha: Boolean;
    BitsSize: Integer;
    bmpDC: HDC;
    bmpHandle: HBITMAP;
  begin
    BitsSize := 4 * SourceColor.Width * SourceColor.Height;
    Bits := AllocMem(BitsSize);
    try
      FillChar(BitmapInfo, SizeOf(BitmapInfo), 0);
      BitmapInfo.bmiHeader.bV4Size := SizeOf(BitmapInfo.bmiHeader);
      BitmapInfo.bmiHeader.bV4Width := SourceColor.Width;
      BitmapInfo.bmiHeader.bV4Height := -SourceColor.Height; //Otherwise the image is upside down.
      BitmapInfo.bmiHeader.bV4Planes := 1;
      BitmapInfo.bmiHeader.bV4BitCount := 32;
      BitmapInfo.bmiHeader.bV4V4Compression := BI_BITFIELDS;
      BitmapInfo.bmiHeader.bV4SizeImage := BitsSize;
      BitmapInfo.bmiColors[0].rgbRed := 255;
      BitmapInfo.bmiColors[1].rgbGreen := 255;
      BitmapInfo.bmiColors[2].rgbBlue := 255;

      { Getting the bitmap Handle will invalidate the Canvas.Handle, so it is important to retrieve them in the correct
        order. As parameter evaluation order is undefined and differs between Win32 and Win64, we get invalid values
        for Canvas.Handle when we use those properties directly in the call to GetDIBits. }
      bmpHandle := SourceColor.Handle;
      bmpDC := SourceColor.Canvas.Handle;
      if GetDIBits(bmpDC, bmpHandle, 0, SourceColor.Height, Bits, BitmapInfoFake, DIB_RGB_COLORS) > 0 then begin
        //Because Win32 API is a piece of crap when it comes to icons, I have to check
        //whether an has an alpha-channel the hard way.
        HasAlpha := False;
        for I := 0 to (SourceColor.Height * SourceColor.Width) - 1 do begin
          if Bits[I].rgbReserved <> 0 then begin
            HasAlpha := True;
            Break;
          end;
        end;
        if HasAlpha then begin
          //OK, so not all alpha-values are 0, which indicates the existence of an
          //alpha-channel.
          I := 0;
          for Y := 0 to SourceColor.Height - 1 do
            for X := 0 to SourceColor.Width - 1 do begin
              MaskLines[Y][X] := Bits[I].rgbReserved;
              Inc(I);
            end;
        end;
      end;
    finally
      FreeMem(Bits, BitsSize);
    end;
  end;

  function WinXPOrHigher: Boolean;
  var
    Info: TOSVersionInfo;
  begin
    Info.dwOSVersionInfoSize := SizeOf(Info);
    GetVersionEx(Info);
    Result := (Info.dwPlatformId = VER_PLATFORM_WIN32_NT) and
      ((Info.dwMajorVersion > 5) or
      ((Info.dwMajorVersion = 5) and (Info.dwMinorVersion >= 1)));
  end;

var
  Temp, SourceColor, SourceMask: TBitmap;
  X, Y: Integer;
  Line: PRGBLine;
  MaskLine, AlphaLine: Vcl.Imaging.pngimage.PByteArray;
  TransparentColor, CurrentColor: TColor;
  IconInfo: TIconInfo;
  AlphaNeeded: Boolean;
begin
  Assert(Dest <> nil, 'Dest is nil!');
  //A PNG does not have to be converted
  if Source is TPngImage then begin
    Dest.Assign(Source);
    Exit;
  end;

  AlphaNeeded := False;
  Temp := TBitmap.Create;
  SetLength(MaskLines, Source.Height);
  for Y := 0 to Source.Height - 1 do begin
    MaskLines[Y] := AllocMem(Source.Width);
    FillMemory(MaskLines[Y], Source.Width, 255);
  end;
  try
    //Initialize intermediate color bitmap
    Temp.Width := Source.Width;
    Temp.Height := Source.Height;
    Temp.PixelFormat := pf24bit;

    //Now figure out the transparency
    if Source is TBitmap then begin
      if Source.Transparent then begin
        //TBitmap is just about comparing the drawn colors against the TransparentColor
        if TBitmap(Source).TransparentMode = tmFixed then
          TransparentColor := TBitmap(Source).TransparentColor
        else
          TransparentColor := TBitmap(Source).Canvas.Pixels[0, Source.Height - 1];

        for Y := 0 to Temp.Height - 1 do begin
          Line := Temp.ScanLine[Y];
          MaskLine := MaskLines[Y];
          for X := 0 to Temp.Width - 1 do begin
            CurrentColor := GetPixel(TBitmap(Source).Canvas.Handle, X, Y);
            if CurrentColor = TransparentColor then begin
              MaskLine^[X] := 0;
              AlphaNeeded := True;
            end;
            Line[X] := ColorToTriple(CurrentColor);
          end;
        end;
      end
      else begin
        Temp.Canvas.Draw(0, 0, Source);
      end;
    end
    else if Source is TIcon then begin
      //TIcon is more complicated, because there are bitmasked (classic) icons and
      //alphablended (modern) icons. Not to forget about the "inverse" color.
      GetIconInfo(TIcon(Source).Handle, IconInfo);
      SourceColor := TBitmap.Create;
      SourceMask := TBitmap.Create;
      try
        SourceColor.Handle := IconInfo.hbmColor;
        SourceMask.Handle := IconInfo.hbmMask;
        Temp.Canvas.Draw(0, 0, SourceColor);
        for Y := 0 to Temp.Height - 1 do begin
          MaskLine := MaskLines[Y];
          for X := 0 to Temp.Width - 1 do begin
            if GetPixel(SourceMask.Canvas.Handle, X, Y) <> 0 then begin
              MaskLine^[X] := 0;
              AlphaNeeded := True;
            end;
          end;
        end;
        if (GetDeviceCaps(SourceColor.Canvas.Handle, BITSPIXEL) = 32) and WinXPOrHigher then begin
          //This doesn't neccesarily mean we actually have 32bpp in the icon, because the
          //bpp of an icon is always the same as the display settings, regardless of the
          //actual color depth of the icon :(
          AlphaNeeded := True;
          GetAlphaMask(SourceColor);
        end;
        //This still doesn't work for alphablended icons...
      finally
        SourceColor.Free;
        SourceMask.Free
      end;
    end;

    //And finally, assign the destination PNG image
    Dest.Assign(Temp);
    if AlphaNeeded then begin
      Dest.CreateAlpha;
      for Y := 0 to Dest.Height - 1 do begin
        AlphaLine := Dest.AlphaScanline[Y];
        CopyMemory(AlphaLine, MaskLines[Y], Temp.Width);
      end;
    end;

  finally
    for Y := 0 to Source.Height - 1 do
      FreeMem(MaskLines[Y], Source.Width);
    Temp.Free;
  end;
end;

procedure CreatePNG(Color, Mask: TBitmap; Dest: TPngImage; InverseMask: Boolean = False);
var
  Temp: TBitmap;
  Line: Vcl.Imaging.pngimage.PByteArray;
  X, Y: Integer;
begin
  Assert(Dest <> nil, 'Dest is nil!');
  //Create a PNG from two separate color and mask bitmaps. InverseMask should be
  //True if white means transparent, and black means opaque.
  if not (Color.PixelFormat in [pf24bit, pf32bit]) then begin
    Temp := TBitmap.Create;
    try
      Temp.Assign(Color);
      Temp.PixelFormat := pf24bit;
      Dest.Assign(Temp);
    finally
      Temp.Free;
    end;
  end
  else begin
    Dest.Assign(Color);
  end;

  //Copy the alpha channel.
  Dest.CreateAlpha;
  for Y := 0 to Dest.Height - 1 do begin
    Line := Dest.AlphaScanline[Y];
    for X := 0 to Dest.Width - 1 do begin
      if InverseMask then
        Line[X] := 255 - (GetPixel(Mask.Canvas.Handle, X, Y) and $FF)
      else
        Line[X] := GetPixel(Mask.Canvas.Handle, X, Y) and $FF;
    end;
  end;
end;

procedure CreatePNGMasked(Bitmap: TBitmap; Mask: TColor; Dest: TPngImage);
var
  Temp: TBitmap;
  Line: Vcl.Imaging.pngimage.PByteArray;
  X, Y: Integer;
begin
  Assert(Dest <> nil, 'Dest is nil!');
  //Create a PNG from two separate color and mask bitmaps. InverseMask should be
  //True if white means transparent, and black means opaque.
  if not (Bitmap.PixelFormat in [pf24bit, pf32bit]) then begin
    Temp := TBitmap.Create;
    try
      Temp.Assign(Bitmap);
      Temp.PixelFormat := pf24bit;
      Dest.Assign(Temp);
    finally
      Temp.Free;
    end;
  end
  else begin
    Dest.Assign(Bitmap);
  end;

  //Copy the alpha channel.
  Dest.CreateAlpha;
  for Y := 0 to Dest.Height - 1 do begin
    Line := Dest.AlphaScanline[Y];
    for X := 0 to Dest.Width - 1 do
      Line[X] := Integer(TColor(GetPixel(Bitmap.Canvas.Handle, X, Y)) <> Mask) * $FF;
  end;
end;

procedure SlicePNG(JoinedPNG: TPngImage; Columns, Rows: Integer; out SlicedPNGs: TObjectList);
var
  X, Y, ImageX, ImageY, OffsetX, OffsetY: Integer;
  Width, Height: Integer;
  Bitmap: TBitmap;
  BitmapLine: PRGBLine;
  AlphaLineA, AlphaLineB: Vcl.Imaging.pngimage.PByteArray;
  PNG: TPngImage;
begin
  //This function slices a large PNG file (e.g. an image with all images for a
  //toolbar) into smaller, equally-sized pictures.
  SlicedPNGs := TObjectList.Create(False);
  Width := JoinedPNG.Width div Columns;
  Height := JoinedPNG.Height div Rows;

  //Loop through the columns and rows to create each individual image
  for ImageY := 0 to Rows - 1 do begin
    for ImageX := 0 to Columns - 1 do begin
      OffsetX := ImageX * Width;
      OffsetY := ImageY * Height;
      Bitmap := TBitmap.Create;
      try
        Bitmap.Width := Width;
        Bitmap.Height := Height;
        Bitmap.PixelFormat := pf24bit;

        //Copy the color information into a temporary bitmap. We can't use TPngImage.Draw
        //here, because that would combine the color and alpha values.
        for Y := 0 to Bitmap.Height - 1 do begin
          BitmapLine := Bitmap.Scanline[Y];
          for X := 0 to Bitmap.Width - 1 do
            BitmapLine[X] := ColorToTriple(JoinedPNG.Pixels[X + OffsetX, Y + OffsetY]);
        end;

        PNG := TPngImage.Create;
        PNG.Assign(Bitmap);

        if JoinedPNG.Header.ColorType in [COLOR_GRAYSCALEALPHA, COLOR_RGBALPHA] then begin
          //Copy the alpha channel
          PNG.CreateAlpha;
          for Y := 0 to PNG.Height - 1 do begin
            AlphaLineA := JoinedPNG.AlphaScanline[Y + OffsetY];
            AlphaLineB := PNG.AlphaScanline[Y];
            for X := 0 to PNG.Width - 1 do
              AlphaLineB[X] := AlphaLineA[X + OffsetX];
          end;
        end;

        SlicedPNGs.Add(PNG);
      finally
        Bitmap.Free;
      end;
    end;
  end;
end;

function TrimInt(Lower, Upper, theInteger: Integer): integer;
begin
  if (theInteger <= Upper) and (theInteger >= Lower) then
    result := theInteger
  else if theInteger > Upper then
    result := Upper
  else
    result := Lower;
end;
function TrimReal(Lower, Upper: Integer; x: Real): integer;
begin
  if (x < upper) and (x >= lower) then
    result := trunc(x)
  else if x > Upper then
    result := Upper
  else
    result := Lower;
end;

procedure BlurRow(var theRow: array of TRGBTriple; K: TKernel; P: PRow);
var
  j, n: Integer;
  tr, tg, tb: Real; {tempRed, etc}
  w: Real;
begin
  for j := 0 to High(theRow) do
  begin
    tb := 0;
    tg := 0;
    tr := 0;
    for n := -K.Size to K.Size do
    begin
      w := K.Weights[n];
      {the TrimInt keeps us from running off the edge of the row...}
      with theRow[TrimInt(0, High(theRow), j - n)] do
      begin
        tb := tb + w * b;
        tg := tg + w * g;
        tr := tr + w * r;
      end;
    end;
    with P[j] do
    begin
      b := TrimReal(0, 255, tb);
      g := TrimReal(0, 255, tg);
      r := TrimReal(0, 255, tr);
    end;
  end;
  Move(P[0], theRow[0], (High(theRow) + 1) * Sizeof(TRGBTriple));
end;

procedure MakeGaussianKernel(var K: TKernel; radius: Real; MaxData, DataGranularity: Real);
{makes K into a gaussian kernel with standard deviation = radius. For the current application
you set MaxData = 255 and DataGranularity = 1. Now the procedure sets the value of K.Size so
that when we use K we will ignore the Weights that are so small they can't possibly matter. (Small
Size is good because the execution time is going to be propertional to K.Size.)}
var
  j: Integer;
  temp, delta: Real;
  KernelSize: TKernelSize;
begin
  for j := Low(K.Weights) to High(K.Weights) do
  begin
    temp := j / radius;
    K.Weights[j] := exp(-temp * temp / 2);
  end;
  {now divide by constant so sum(Weights) = 1:}
  temp := 0;
  for j := Low(K.Weights) to High(K.Weights) do
    temp := temp + K.Weights[j];
  for j := Low(K.Weights) to High(K.Weights) do
    K.Weights[j] := K.Weights[j] / temp;
  {now discard (or rather mark as ignorable by setting Size) the entries that are too small to matter.
  This is important, otherwise a blur with a small radius will take as long as with a large radius...}
  KernelSize := 50;
  delta := DataGranularity / (2 * MaxData);
  temp := 0;
  while (temp < delta) and (KernelSize > 1) do
  begin
    temp := temp + 2 * K.Weights[KernelSize];
    dec(KernelSize);
  end;
  K.Size := KernelSize;
  {now just to be correct go back and jiggle again so the sum of the entries we'll be using is exactly 1}
  temp := 0;
  for j := -K.Size to K.Size do
    temp := temp + K.Weights[j];
  for j := -K.Size to K.Size do
    K.Weights[j] := K.Weights[j] / temp;
  // finally correct
  K.Weights[0] := K.Weights[0] + (0.000001);// HACK
end;

procedure GaussianBlur(Bitmap: TBitmap; Radius: Real);
var
  Row, Col: Integer;
  theRows: PPRows;
  K: TKernel;
  ACol: PRow;
  P: PRow;
begin
  if (Bitmap.HandleType <> bmDIB) or (Bitmap.PixelFormat <> pf24Bit) then
    raise Exception.Create('GaussianBlur only works for 24-bit bitmaps');
  MakeGaussianKernel(K, radius, 255, 1);
  GetMem(theRows, Bitmap.Height * SizeOf(PRow));
  GetMem(ACol, Bitmap.Height * SizeOf(TRGBTriple));
  {record the location of the bitmap data:}
  for Row := 0 to Bitmap.Height - 1 do
    theRows[Row] := Bitmap.Scanline[Row];
  {blur each row:}
  P := AllocMem(Bitmap.Width * SizeOf(TRGBTriple));
  for Row := 0 to Bitmap.Height - 1 do
    BlurRow(Slice(theRows[Row]^, Bitmap.Width), K, P);
  {now blur each column}
  ReAllocMem(P, Bitmap.Height * SizeOf(TRGBTriple));
  for Col := 0 to Bitmap.Width - 1 do
  begin
    {first read the column into a TRow:}
    for Row := 0 to Bitmap.Height - 1 do
      ACol[Row] := theRows[Row][Col];
    BlurRow(Slice(ACol^, Bitmap.Height), K, P);
    {now put that row, um, column back into the data:}
    for Row := 0 to Bitmap.Height - 1 do
      theRows[Row][Col] := ACol[Row];
  end;
  FreeMem(theRows);
  FreeMem(ACol);
  ReAllocMem(P, 0);
end;
// *** End changed GBlur2.pas ***
procedure FastBlur(Bitmap: TBitmap; Radius: Real; BlurScale: Integer; HighQuality: Boolean = True);
  function Max(A, B: Integer): Integer;
  begin
    if A > B then
      Result := A
    else
      Result := B;
  end;
var
  Mipmap: TBitmap;
begin
  BlurScale := Max(BlurScale, 1);
  Mipmap := TBitmap.Create;
  try
    Mipmap.PixelFormat := pf24bit;
    Mipmap.SetSize(Max(Bitmap.Width div BlurScale, 4), Max(Bitmap.Height div BlurScale, 4));
    // create mipmap
    if HighQuality then
      DrawBitmapHighQuality(Mipmap.Canvas.Handle, Rect(0, 0, Mipmap.Width, Mipmap.Height), Bitmap, 255, False, True)
    else
      Mipmap.Canvas.StretchDraw(Rect(0, 0, Mipmap.Width, Mipmap.Height), Bitmap);
    // gaussian blur
    GaussianBlur(Mipmap, Radius);
    // stretch to source bitmap
    DrawBitmapHighQuality(Bitmap.Canvas.Handle, Rect(0, 0, Bitmap.Width, Bitmap.Height), Mipmap, 255, False, True);
  finally
    Mipmap.Free;
  end;
end;

procedure MakeStar(Canvas : TCanvas; cX, cY, size : integer; Colour :TColor; bordersize: integer; bordercolor: TColor);
var
  Pent : TPent;
begin
  Pent := MakePent(cX, cY, size);

  BeginPath(Canvas.Handle);

  DrawPentacle(Canvas, Pent);

  EndPath(Canvas.Handle);

  SetPolyFillMode(Canvas.Handle, WINDING);

  if bordersize <> 0 then
    Canvas.Brush.Color := bordercolor
  else
    Canvas.Brush.Color := Colour;

  FillPath(Canvas.Handle);

  if bordersize <> 0 then begin
    Pent := MakePent(cX, cY + trunc(bordersize / 1.2), size - bordersize);
    BeginPath(Canvas.Handle);
    DrawPentacle(Canvas, Pent);
    EndPath(Canvas.Handle);
    SetPolyFillMode(Canvas.Handle, WINDING);
    Canvas.Brush.Color := Colour;
    FillPath(Canvas.Handle);
  end;
end;

end.
