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
    Vcl.Forms, System.SysUtils, Imaging.pngimage, Imaging.GIFImg, Imaging.jpeg,
    Cod.ColorUtils, Cod.VarHelpers, Cod.Types, Cod.StringUtils, Cod.GDI,
    Cod.ArrayHelpers;

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

    // Items
    TPent = array[0..4] of TPoint;
    TDrawMode = (Fill, Fit, Stretch, Center, CenterFill, Center3Fill,
      CenterFit, Normal, Tile); { Windows DWM use a Center3 Fill }

    TTextFlag = (WordWrap, Top, VerticalCenter, Bottom, Left, Center, Right,
      NoClip, Auto);
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
  procedure DrawLine(Canvas: TCanvas; Line: TLine);
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
  procedure DrawImageInRect(Canvas: TCanvas; Rect: TRect; Image: TGraphic;
    DrawMode: TDrawMode = TDrawMode.Fill; ImageMargin: integer = 0;
    ClipImage: boolean = false);
  function GetDrawModeRects(Rect: TRect; Image: TGraphic; DrawMode:
    TDrawMode = TDrawMode.Fill; ImageMargin: integer = 0): TArray<TRect>; overload;
  function GetDrawModeRect(Rect: TRect; Image: TGraphic; DrawMode:
    TDrawMode = TDrawMode.Fill; ImageMargin: integer = 0): TRect; overload;

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

      // Lines
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
          Words.Insert(I+1, Temp);

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

procedure DrawLine(Canvas: TCanvas; Line: TLine);
begin
  with Canvas do begin
    MoveTo(Line.Point1.X, Line.Point1.Y);
    LineTo(Line.Point2.X, Line.Point2.Y);
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

function GetDrawModeRects(Rect: TRect; Image: TGraphic; DrawMode: TDrawMode; ImageMargin: integer): TArray<TRect>;
var
  A, B, C: real;
  TMPRect: TRect;
  W, H: Integer;
begin
  // Empty Image
  if Image.Empty then
    Exit;

  // Shrink Margins
  Rect.Inflate(-ImageMargin, -ImageMargin);

  // Load
  SetLength(Result, 1);
  if Image <> nil then
  case DrawMode of
    // Fill
    TDrawMode.Fill: begin
      Result[0] := Rect;

      A := Result[0].Width / Image.Width ;
      B := Image.Height * A;

      if B < Result[0].Height then
        begin
          C := Result[0].Height / Image.Height;

          Result[0].Width := trunc(Image.Width * C);
        end
          else
            Result[0].Height := trunc(B);
    end;
    // Fit
    TDrawMode.Fit: begin
      Result[0] := Rect;

      A := Result[0].Width / Image.Width ;
      B := Image.Height * A;

      if B > Result[0].Height then
        begin
          C := Result[0].Height / Image.Height;

          Result[0].Width := trunc(Image.Width * C);
        end
          else
            Result[0].Height := trunc(B);
    end;
    // Stretch
    TDrawMode.Stretch: begin
      Result[0] := Rect;
    end;
    // Center
    TDrawMode.Center: begin
      Result[0].Left := Rect.CenterPoint.X - Image.Width div 2;
      Result[0].Right := Rect.CenterPoint.X + Image.Width div 2;

      Result[0].Top := Rect.CenterPoint.Y - Image.Height div 2;
      Result[0].Bottom := Rect.CenterPoint.Y + Image.Height div 2;
    end;
    // Center Fill
    TDrawMode.CenterFill: begin
      Result[0] := Rect;

      A := Result[0].Width / Image.Width ;
      B := Image.Height * A;

      if B < Result[0].Height then
        begin
          C := Result[0].Height / Image.Height;

          Result[0].Width := trunc(Image.Width * C);
        end
          else
            Result[0].Height := trunc(B);

      W := Result[0].Width;
      H := Result[0].Height;

      Result[0].Left := Result[0].Left - (W - Rect.Width) div 2;
      Result[0].Right := Result[0].Right - (W - Rect.Width) div 2;
      Result[0].Top := Result[0].Top - (H - Rect.Height) div 2;
      Result[0].Bottom := Result[0].Bottom - (H - Rect.Height) div 2;
    end;
    // Center Fill
    TDrawMode.Center3Fill: begin
      Result[0] := Rect;

      A := Result[0].Width / Image.Width ;
      B := Image.Height * A;

      if B < Result[0].Height then
        begin
          C := Result[0].Height / Image.Height;

          Result[0].Width := trunc(Image.Width * C);
        end
          else
            Result[0].Height := trunc(B);

      W := Result[0].Width;
      H := Result[0].Height;

      Result[0].Left := Result[0].Left - (W - Rect.Width) div 3;
      Result[0].Right := Result[0].Right - (W - Rect.Width) div 3;
      Result[0].Top := Result[0].Top - (H - Rect.Height) div 3;
      Result[0].Bottom := Result[0].Bottom - (H - Rect.Height) div 3;
    end;
    // Center Fit
    TDrawMode.CenterFit: begin
      Result[0] := Rect;

      A := Result[0].Width / Image.Width ;
      B := Image.Height * A;

      if B > Result[0].Height then
        begin
          C := Result[0].Height / Image.Height;

          Result[0].Width := trunc(Image.Width * C);
        end
          else
            Result[0].Height := trunc(B);

      W := Result[0].Width;
      H := Result[0].Height;

      Result[0].Left := Result[0].Left + (Rect.Width - W) div 2;
      Result[0].Right := Result[0].Right + (Rect.Width - W) div 2;
      Result[0].Top := Result[0].Top + (Rect.Height - H) div 2;
      Result[0].Bottom := Result[0].Bottom + (Rect.Height - H) div 2;
    end;
    // Normal
    TDrawMode.Normal: begin
      Result[0].Left := Rect.Left;
      Result[0].Right := Result[0].Left + Image.Width;

      Result[0].Top := Rect.Top;
      Result[0].Bottom := Result[0].Bottom + Image.Height;
    end;
    // Tile
    TDrawMode.Tile: begin
      SetLength(Result, 0);
      A := Rect.Top;
      repeat
        B := Rect.Left;
        repeat
          SetLength(Result, Length(Result) + 1);

          TMPRect.TopLeft := Point(trunc(B), trunc(A));
          TMPRect.Width := Image.Width;
          TMPRect.Height := Image.Height;

          Result[Length(Result) - 1] := TMPRect;

          B := B + Image.Width;
        until (B >= Rect.Width);

        A := A + Image.Height;
      until (A >= Rect.Height);
    end;
  end;
end;

function GetDrawModeRect(Rect: TRect; Image: TGraphic; DrawMode: TDrawMode; ImageMargin: integer): TRect;
begin
  Result := GetDrawModeRects(Rect, Image, DrawMode, ImageMargin)[0];
end;

procedure DrawImageInRect(Canvas: TCanvas; Rect: TRect; Image: TGraphic; DrawMode: TDrawMode; ImageMargin: integer; ClipImage: boolean);
var
  Rects: TArray<TRect>;
  I: integer;
  Bitmap: TBitMap;
  FRect: TRect;
begin
  // Shrink Margins
  Rect.Inflate(-ImageMargin, -ImageMargin);

  // Get Rectangles
  Rects := GetDrawModeRects(Rect, Image, DrawMode, 0{Margins already defalted});

  if not ClipImage then
    // Standard Draw
    begin
      for I := 0 to High( Rects ) do
        Canvas.StretchDraw( Rects[I], Image, 255 );
    end
  else
    // Clip Image Drw
    begin
      for I := 0 to High(Rects) do
        begin
          Bitmap := TBitMap.Create;
          try
            FRect := Rects[I];
            FRect.Offset( -Rect.Left, -Rect.Top );

            Bitmap.Width := Rect.Width;
            Bitmap.Height := Rect.Height;

            Bitmap.Canvas.StretchDraw(FRect, Image, 255);

            Canvas.StretchDraw(Rect, BitMap, 255)
            //Canvas.Draw(Rect.Top, Rect.Left, BitMap);
          finally
            BitMap.Free;
          end;
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
