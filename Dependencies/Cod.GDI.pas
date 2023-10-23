{***********************************************************}
{                    Codruts GDI Library                    }
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

unit Cod.GDI;

interface
  uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Imaging.pngimage, Imaging.GIFImg, Imaging.jpeg, Winapi.GDIPAPI,
  Winapi.GDIPOBJ, Cod.ColorUtils, Cod.Types;

  type
    // Requirements
    THackGraphic = class(TGraphic);
    TRGBAArray = array[Word] of TRGBQuad;
    PRGBAArray = ^TRGBAArray;
    TRGBArray = array[Word] of TRGBTriple;
    PRGBArray = ^TRGBArray;

    TGDIBrush = TGPSolidBrush;
    TGDIPen = TGPPen;

    function MakeBrush(Color: TColor; Opacity: byte = 255): TGDIBrush; overload;
    function MakeBrush(R, G, B: Byte; Opacity: byte = 255): TGDIBrush; overload;

    function MakePen(Color: TColor; Width: Single = 1; Opacity: byte = 255): TGDIPen; overload;
    function MakePen(R, G, B: Byte; Width: Single = 1; Opacity: byte = 255): TGDIPen; overload;

    // Effects
    procedure TintPicture(Canvas: TCanvas; Rectangle: TRect; Color: TColor = clBlack; Opacity: byte = 75; Buffered: boolean = true);

    // Drawing functions
    procedure DrawText(Canvas: TCanvas; Text: string; Rectangle: TRect; Font: TGPFont; Format: TGPStringFormat; Brush: TGDIBrush; Angle: integer = 0; Buffered: boolean = false);
    procedure DrawRectangle(Canvas: TCanvas; Rectangle: TRect; Brush: TGDIBrush; Pen: TGDIPen; Buffered: boolean = true);
    procedure DrawRoundRect(Canvas: TCanvas; RoundRect: TRoundRect; Brush: TGDIBrush; Pen: TGDIPen; Buffered: boolean = true);
    procedure DrawCircle(Canvas: TCanvas; Rectangle: TRect; Brush: TGDIBrush; Pen: TGDIPen; Buffered: boolean = true);
    procedure DrawPolygon(Canvas: TCanvas; Points: TArray<TPoint>; Brush: TGDIBrush; Pen: TGDIPen; Buffered: boolean = true);
    procedure DrawLine(Canvas: TCanvas; Line: TLine; Pen: TGDIPen; Buffered: boolean = true);
    procedure DrawGraphic(Canvas: TCanvas; Graphic: TGraphic; Rect: TRect; Angle: integer = 0; Buffered: boolean = true);
    procedure DrawGraphicRound(Canvas: TCanvas; Graphic: TGraphic; Rect: TRect; Roundness: real; Buffered: boolean = true);
    procedure GraphicStretchDraw(Canvas: TCanvas; Rect: TRect; Graphic: TGraphic; Opacity: Byte); overload;
    procedure GraphicStretchDraw(Canvas: TCanvas; DestRect, SrcRect: TRect; Bitmap: TBitmap; Opacity: Byte); overload;
    procedure DrawGraphicHighQuality(Canvas: TCanvas; ARect: TRect; Graphic: TGraphic; Opacity: Byte = 255; HighQuality: Boolean = False); overload;
    procedure DrawGraphicHighQuality(Canvas: TCanvas; ARect: TRect; Bitmap: TBitmap; Opacity: Byte = 255; HighQuality: Boolean = False); overload;

    // Utils
    procedure GraphicAssignToBitmap(Bitmap: TBitmap; Graphic: TGraphic);
    procedure PngImageAssignToBitmap(Bitmap: TBitmap; PngImage: TPngImage; IsPremultipledBitmap: Boolean = True);
    procedure DrawBitmapHighQuality(Handle: THandle; ARect: TRect; Bitmap: TBitmap; Opacity: Byte = 255;
    HighQality: Boolean = False; EgdeFill: Boolean = False);

implementation

function MakeBrush(Color: TColor; Opacity: byte = 255): TGDIBrush;
var
  RGB: CRGB;
begin
  RGB := GetRGB( Color );

  Result := TGDIBrush.Create( MakeColor(RGB.R, RGB.G, RGB.B, Opacity) );
end;

function MakeBrush(R, G, B: Byte; Opacity: byte = 255): TGDIBrush;
begin
  Result := TGDIBrush.Create( MakeColor(R, G, B, Opacity) );
end;

function MakePen(Color: TColor; Width: Single = 1; Opacity: byte = 255): TGDIPen; overload;
var
  RGB: CRGB;
begin
  RGB := GetRGB( Color );

  Result := TGDIPen.Create( MakeColor(RGB.R, RGB.G, RGB.B, Opacity), Width );
end;

function MakePen(R, G, B: Byte; Width: Single = 1; Opacity: byte = 255): TGDIPen; overload;
begin
  Result := TGDIPen.Create( MakeColor(R, G, B, Opacity), Width );
end;

procedure PrepareBMP(bmp: TBitmap; Width, Height: Integer);
var
  p: Pointer;
begin
  bmp.PixelFormat := pf32Bit;
  bmp.Width := Width;
  bmp.Height := Height;
  bmp.HandleType := bmDIB;
  bmp.ignorepalette := true;
  bmp.alphaformat := afPremultiplied;
  // clear all Scanlines
  if Height > 0 then
  begin
    p := bmp.ScanLine[Height - 1];
    ZeroMemory(p, Width * Height * 4);
  end;
end;

procedure TintPicture(Canvas: TCanvas; Rectangle: TRect; Color: TColor; Opacity: byte; Buffered: boolean);
var
  G: TGPGRaphics;
  B: TGDIBrush;
begin
  // Bitmap Buffered Draw
  if Buffered then
    begin
      var BMP: TBitMap;
      var R: TRect;

      BMP := TBitMap.Create;
      PrepareBMP(BMP, Rectangle.Width, Rectangle.Height);
      try
        R := Rectangle;
        R.Offset(-Rectangle.Left, -Rectangle.Top);

        TintPicture( BMP.Canvas, R, Color, Opacity, false);

        Canvas.Draw(Rectangle.Left, Rectangle.Top, BMP);
      finally
        BMP.Free;
      end;
      Exit;
    end;

  // Client Draw
  G := TGPGRaphics.Create(Canvas.Handle);
  B := GetRGB(Color, Opacity).MakeGDIBrush;
  try
    G.SetSmoothingMode(SmoothingModeHighQuality);


    G.FillRectangle(B, MakeRect(Rectangle));

    // Canvas Notify
    if Assigned(Canvas.OnChange) then
      Canvas.OnChange(Canvas);
  finally
    G.Free;
    B.Free;
  end;
end;

procedure DrawText(Canvas: TCanvas; Text: string; Rectangle: TRect; Font: TGPFont; Format: TGPStringFormat; Brush: TGDIBrush; Angle: integer; Buffered: boolean);
var
  G: TGPGRaphics;
begin
  // Bitmap Buffered Draw
  if Buffered then
    begin
      var BMP: TBitMap;
      var R: TRect;

      BMP := TBitMap.Create;
      PrepareBMP(BMP, Rectangle.Width, Rectangle.Height);
      try
        R := Rectangle;
        R.Offset(-Rectangle.Left, -Rectangle.Top);

        DrawText( BMP.Canvas, Text, R, Font, Format, Brush, Angle, false);

        Canvas.Draw(Rectangle.Left, Rectangle.Top, BMP);
      finally
        BMP.Free;
      end;
      Exit;
    end;

  // Client Draw
  G := TGPGRaphics.Create(Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeHighQuality);

    G.TranslateTransform(Rectangle.Left + Rectangle.Width div 2, Rectangle.Top + Rectangle.Height div 2);
    Rectangle.Offset(-Rectangle.Left - Rectangle.Width div 2, -Rectangle.Top - Rectangle.Height div 2);

     if Angle <> 0 then
      // Rotate
      G.RotateTransform(Angle);

    if Brush <> nil then
      begin
        const R: TGPRectF = MakeRect(Single(Rectangle.Left), Rectangle.Top, Rectangle.Width, Rectangle.Height);
        G.DrawString(PChar(Text), -1, Font, R, Format, Brush );
      end;

    // Reset Rotation
    G.ResetTransform;

    // Canvas Notify
    if Assigned(Canvas.OnChange) then
      Canvas.OnChange(Canvas);
  finally
    G.Free;
  end;
end;

procedure DrawRectangle(Canvas: TCanvas; Rectangle: TRect; Brush: TGDIBrush; Pen: TGDIPen; Buffered: boolean);
var
  G: TGPGRaphics;
begin
  // Bitmap Buffered Draw
  if Buffered then
    begin
      var BMP: TBitMap;
      var R: TRect;
      var PenWidth: integer;

      if Pen <> nil then
        PenWidth := trunc(Pen.GetWidth)
      else
        PenWidth := 0;

      BMP := TBitMap.Create;
      PrepareBMP(BMP, Rectangle.Width + PenWidth * 2, Rectangle.Height + PenWidth * 2);
      try
        R := Rectangle;
        R.Offset(-Rectangle.Left + PenWidth, -Rectangle.Top + PenWidth);

        DrawRectangle( BMP.Canvas, R, Brush, Pen, false);

        Canvas.Draw(Rectangle.Left - PenWidth, Rectangle.Top - PenWidth, BMP);
      finally
        BMP.Free;
      end;
      Exit;
    end;

  // Client Draw
  G := TGPGRaphics.Create(Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeHighQuality);
    if Brush <> nil then
      G.FillRectangle(Brush, MakeRect(Rectangle));

    if Pen <> nil then
      G.DrawRectangle(Pen, MakeRect(Rectangle));

    // Canvas Notify
    if Assigned(Canvas.OnChange) then
      Canvas.OnChange(Canvas);
  finally
    G.Free;
  end;
end;

procedure DrawRoundRect(Canvas: TCanvas; RoundRect: TRoundRect; Brush: TGDIBrush; Pen: TGDIPen; Buffered: boolean);
var
  G: TGPGRaphics;
  GPath: TGPGraphicsPath;
begin
  // Bitmap Buffered Draw
  if Buffered then
    begin
      var BMP: TBitMap;
      var R: TRoundRect;
      var PenWidth: integer;

      if Pen <> nil then
        PenWidth := trunc(Pen.GetWidth)
      else
        PenWidth := 0; 
                                                                      
      BMP := TBitMap.Create;
      PrepareBMP(BMP, RoundRect.Width + PenWidth * 2, RoundRect.Height + PenWidth * 2);
      try
        R := RoundRect;  
        R.Offset(-RoundRect.Left + PenWidth, -RoundRect.Top + PenWidth);
        
        DrawRoundRect( BMP.Canvas, R, Brush, Pen, false);

        Canvas.Draw(RoundRect.Left - PenWidth, RoundRect.Top - PenWidth, BMP);
      finally
        BMP.Free;
      end;
      Exit;  
    end;

  // Client Draw
  G := TGPGRaphics.Create(Canvas.Handle);
  GPath := TGPGraphicsPath.Create;
  try
    G.SetSmoothingMode(SmoothingModeHighQuality);

    // Make Path
    with RoundRect do
      begin
        GPath.AddArc(Left, Top, RoundTL, RoundTL, 180, 90); // topleft
        GPath.AddArc(Left + Width - RoundTR, Top, RoundTR, RoundTR, 270, 90); // topright
        GPath.AddArc(Left + Width - RoundBR, Top + Height - RoundBR, RoundBR, RoundBR, 0, 90); // bottomright
        GPath.AddArc(Left, Top + Height - RoundBL, RoundBL, RoundBL, 90, 90); // bottomleft
        GPath.CloseFigure();
      end;

    // Draw
    if Brush <> nil then
     G.FillPath(Brush, GPath);

    if Pen <> nil then
      G.DrawPath(Pen, GPath);

    // Canvas Notify
    if Assigned(Canvas.OnChange) then
      Canvas.OnChange(Canvas);
  finally
    G.Free;
    GPath.Free;
  end;
end;

procedure DrawCircle(Canvas: TCanvas; Rectangle: TRect; Brush: TGDIBrush; Pen: TGDIPen; Buffered: boolean);
var
  G: TGPGRaphics;
begin
  // Bitmap Buffered Draw
  if Buffered then
    begin
      var BMP: TBitMap;
      var R: TRect;
      var PenWidth: integer;

      if Pen <> nil then
        PenWidth := trunc(Pen.GetWidth)
      else
        PenWidth := 0;
      
      BMP := TBitMap.Create;
      PrepareBMP(BMP, Rectangle.Width + PenWidth * 2, Rectangle.Height + PenWidth * 2);
      try
        R := Rectangle;
        R.Offset(-Rectangle.Left + PenWidth, -Rectangle.Top + PenWidth);
        
        DrawCircle( BMP.Canvas, R, Brush, Pen, false);

        Canvas.Draw(Rectangle.Left - PenWidth, Rectangle.Top - PenWidth, BMP);
      finally
        BMP.Free;
      end;
      Exit;  
    end;
    
  // Client Draw
  G := TGPGRaphics.Create(Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeHighQuality);
    if Brush <> nil then
      G.FillEllipse(Brush, MakeRect(Rectangle));

    if Pen <> nil then
      G.DrawEllipse(Pen, MakeRect(Rectangle));

    // Canvas Notify
    if Assigned(Canvas.OnChange) then
      Canvas.OnChange(Canvas);
  finally
    G.Free;
  end;
end;

procedure DrawPolygon(Canvas: TCanvas; Points: TArray<TPoint>; Brush: TGDIBrush; Pen: TGDIPen; Buffered: boolean);
var
  G: TGPGRaphics;
  I: Integer;
  PPoints: TPointDynArray;
begin
  // Bitmap Buffered Draw
  if Buffered then
    begin
      var BMP: TBitMap;
      var R: TRect;
      var P: TArray<TPoint>;
      var PenWidth: integer;

      if Pen <> nil then
        PenWidth := trunc(Pen.GetWidth)
      else
        PenWidth := 0;
      
      BMP := TBitMap.Create;
      R := GetValidRect( Points );
      PrepareBMP(BMP, R.Width + PenWidth * 2, R.Height + PenWidth * 2);
      try
        P := Points;
        for I := 0 to High(P) do
          P[I].Offset(-R.Left  + PenWidth, -R.Top + PenWidth);
        
        DrawPolygon( BMP.Canvas, P, Brush, Pen, false);

        Canvas.Draw(R.Left - PenWidth, R.Top - PenWidth, BMP);
      finally
        BMP.Free;
      end;
      Exit;  
    end;
    
  // Client Draw
  G := TGPGRaphics.Create(Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeHighQuality);

    SetLength( PPoints, Length(Points));
    for I := 0 to High(Points) do
      PPoints[I] := MakePoint( Points[I].X, Points[I].Y );

    if Brush <> nil then
      G.FillPolygon(Brush, PGPPoint(@PPoints[0]), Length(PPoints));

    if Pen <> nil then
      G.DrawPolygon(Pen, PGPPoint(@PPoints[0]), Length(PPoints));

    // Canvas Notify
    if Assigned(Canvas.OnChange) then
      Canvas.OnChange(Canvas);
  finally
    G.Free;
  end;
end;

procedure DrawLine(Canvas: TCanvas; Line: TLine; Pen: TGDIPen; Buffered: boolean);
var
  G: TGPGRaphics;
begin
  // Bitmap Buffered Draw
  if Buffered then
    begin
      var BMP: TBitMap;
      var R: TLine;
      var PenWidth: integer;

      if Pen <> nil then
        PenWidth := trunc(Pen.GetWidth)
      else
        PenWidth := 0;
      
      BMP := TBitMap.Create;
      PrepareBMP(BMP, Line.GetWidth + PenWidth * 2, Line.GetHeight + PenWidth * 2);
      try
        R := Line;     
        R.Offset(-Line.Rect.Left + PenWidth, -Line.Rect.Top + PenWidth);
        
        DrawLine( BMP.Canvas, R, Pen, false);

        Canvas.Draw(Line.Rect.Left - PenWidth, Line.Rect.Top - PenWidth, BMP);
      finally
        BMP.Free;
      end;
      Exit;
    end;

  // Client Draw
  G := TGPGRaphics.Create(Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeHighQuality);

    if Pen <> nil then
      G.DrawLine( Pen, MakePoint(Line.Point1.X, Line.Point1.Y), MakePoint(Line.Point2.X, Line.Point2.Y) );

    // Canvas Notify
    if Assigned(Canvas.OnChange) then
      Canvas.OnChange(Canvas);
  finally
    G.Free;
  end;
end;

procedure DrawGraphic(Canvas: TCanvas; Graphic: TGraphic; Rect: TRect; Angle: integer; Buffered: boolean);
var
  G: TGPGRaphics;
  P: TGPImage;
  BitMap: TBitMap;
begin
  // Bitmap Buffered Draw
  if Buffered then
    begin
      var BMP: TBitMap;
      var R: TRect;

      BMP := TBitMap.Create;
      PrepareBMP(BMP, Rect.Width, Rect.Height);
      try
        R := Rect;
        R.Offset(-Rect.Left, -Rect.Top);

        DrawGraphic( BMP.Canvas, Graphic, R, 0, false);

        Canvas.Draw(Rect.Left, Rect.Top, BMP);
      finally
        BMP.Free;
      end;
      Exit;
    end;

  // Client Draw
  G := TGPGRaphics.Create(Canvas.Handle);
  BitMap := TBitMap.Create;
  try
    G.SetSmoothingMode(SmoothingModeHighQuality);

    G.TranslateTransform(Rect.Left + Rect.Width div 2, Rect.Top + Rect.Height div 2);
    Rect.Offset(-Rect.Left - Rect.Width div 2, -Rect.Top - Rect.Height div 2);
    BitMap.Assign(Graphic);

    if Angle <> 0 then
      // Rotate
      G.RotateTransform(Angle);

    P := TGPBitmap.Create(Bitmap.Handle, Bitmap.Palette);
    try
      G.DrawImage(P, MakeRect(Rect));
    finally
      P.Free;
    end;

    // Reset Rotation
    G.ResetTransform;

    // Canvas Notify
    if Assigned(Canvas.OnChange) then
      Canvas.OnChange(Canvas);
  finally
    G.Free;
    BitMap.Free;
  end;
end;

procedure DrawGraphicRound(Canvas: TCanvas; Graphic: TGraphic; Rect: TRect; Roundness: real; Buffered: boolean);
var
  G: TGPGRaphics;
  P: TGPImage;
  BitMap: TBitMap;
  RoundPath: TGPGraphicsPath;
begin
  // Bitmap Buffered Draw
  if Buffered then
    begin
      var BMP: TBitMap;
      var R: TRect;

      BMP := TBitMap.Create;
      PrepareBMP(BMP, Rect.Width, Rect.Height);
      try
        R := Rect;
        R.Offset(-Rect.Left, -Rect.Top);

        DrawGraphicRound( BMP.Canvas, Graphic, R, Roundness, false);

        Canvas.Draw(Rect.Left, Rect.Top, BMP);
      finally
        BMP.Free;
      end;
      Exit;
    end;

  // Client Draw
  G := TGPGRaphics.Create(Canvas.Handle);
  BitMap := TBitMap.Create;
  try
    G.SetSmoothingMode(SmoothingModeHighQuality);

    BitMap.Assign(Graphic);

    P := TGPBitmap.Create(Bitmap.Handle, Bitmap.Palette);
    try
      G.SetClip(MakeRect(Rect));
      RoundPath := TGPGraphicsPath.Create();
      try
        // Add a rounded rectangle to the path
        RoundPath.AddArc(Rect.Left, Rect.Top, Roundness, Roundness, 180, 90);
        RoundPath.AddArc(Rect.Right - Roundness, Rect.Top, Roundness, Roundness, 270, 90);
        RoundPath.AddArc(Rect.Right - Roundness, Rect.Bottom - Roundness, Roundness, Roundness, 0, 90);
        RoundPath.AddArc(Rect.Left, Rect.Bottom - Roundness, Roundness, Roundness, 90, 90);
        RoundPath.CloseFigure;

        // Clip & Draw
        G.SetClip(RoundPath);
        G.DrawImage(P, MakeRect(Rect));
      finally
        RoundPath.Free;
      end;
    finally
      P.Free;
    end;

    // Canvas Notify
    if Assigned(Canvas.OnChange) then
      Canvas.OnChange(Canvas);
  finally
    G.Free;
    BitMap.Free;
  end;
end;

procedure GraphicStretchDraw(Canvas: TCanvas; DestRect, SrcRect: TRect; Bitmap: TBitmap; Opacity: Byte);
var
  BF: TBlendFunction;
begin
  if Bitmap.Empty then
    Exit;
  BF.BlendOp := AC_SRC_OVER;
  BF.BlendFlags := 0;
  BF.SourceConstantAlpha := Opacity;
  if Bitmap.PixelFormat = pf32bit then
    BF.AlphaFormat := AC_SRC_ALPHA
  else
    BF.AlphaFormat := 0;
  AlphaBlend(Canvas.Handle, DestRect.Left, DestRect.Top, DestRect.Right - DestRect.Left, DestRect.Bottom - DestRect.Top,
    Bitmap.Canvas.Handle, SrcRect.Left, SrcRect.Top, SrcRect.Right - SrcRect.Left, SrcRect.Bottom - SrcRect.Top, BF);
end;

procedure DrawGraphicHighQuality(Canvas: TCanvas; ARect: TRect; Bitmap: TBitmap; Opacity: Byte = 255; HighQuality: Boolean = False);
begin
  DrawBitmapHighQuality(Canvas.Handle, ARect, Bitmap, Opacity, HighQuality);

  // Canvas Notify
  if Assigned(Canvas.OnChange) then
    Canvas.OnChange(Canvas);
end;

procedure DrawGraphicHighQuality(Canvas: TCanvas; ARect: TRect; Graphic: TGraphic; Opacity: Byte; HighQuality: Boolean);
var
  Bitmap: TBitmap;
begin
  if Graphic is TBitmap then
    DrawGraphicHighQuality(Canvas, ARect, TBitmap(Graphic), Opacity, HighQuality)
  else
  begin
    Bitmap := TBitmap.Create;
    try
      GraphicAssignToBitmap(Bitmap, Graphic);
      DrawGraphicHighQuality(Canvas, ARect, Bitmap, Opacity, HighQuality);
    finally
      Bitmap.Free;
    end;
  end;
end;

procedure GraphicStretchDraw(Canvas: TCanvas; Rect: TRect; Graphic: TGraphic; Opacity: Byte);
var
  Bitmap: TBitmap;
begin
  if Graphic <> nil then
  begin
    if Assigned(Canvas.OnChanging) then
      Canvas.OnChanging(Canvas);

    //RequiredState([csHandleValid]);
    if Opacity = 255 then
      THackGraphic(Graphic).Draw(Canvas, Rect)
    else
      // for Opacity <> 255
      if Graphic is TBitmap then
      begin
        // god scenary
        THackGraphic(Graphic).DrawTransparent(Canvas, Rect, Opacity);
      end
      else
      begin
        // bed, we create temp buffer, it is slowly :(
        Bitmap := TBitmap.Create;
        try
          GraphicAssignToBitmap(Bitmap, Graphic);
          GraphicStretchDraw(Canvas, Rect, Bitmap, Opacity);
        finally
          Bitmap.Free;
        end;
      end;

    // Canvas Notift
    if Assigned(Canvas.OnChange) then
      Canvas.OnChange(Canvas);
  end;
end;

// Utils

procedure DrawBitmapHighQuality(Handle: THandle; ARect: TRect; Bitmap: TBitmap; Opacity: Byte = 255;
  HighQality: Boolean = False; EgdeFill: Boolean = False);
var
  Graphics: TGPGraphics;
  GdiPBitmap: TGPBitmap;
  Attr: TGPImageAttributes;
  M: TColorMatrix;
begin
  if Bitmap.Empty then
    Exit;
  GdiPBitmap := nil;
  Graphics := TGPGraphics.Create(Handle);
  try
    Graphics.SetSmoothingMode(SmoothingModeDefault);
    Graphics.SetPixelOffsetMode(PixelOffsetModeHalf);
    if not HighQality then
      Graphics.SetInterpolationMode(InterpolationModeHighQualityBilinear)
    else
      Graphics.SetInterpolationMode(InterpolationModeHighQuality);
    if Bitmap.PixelFormat = pf32bit then
    begin
      Assert(Bitmap.HandleType = bmDIB);
      GdiPBitmap := TGPBitmap.Create(Bitmap.Width, Bitmap.Height, -Bitmap.Width * 4,
        PixelFormat32bppPARGB, Bitmap.ScanLine[0]);
    end else
    if Bitmap.PixelFormat = pf24bit then
    begin
      Assert(Bitmap.HandleType = bmDIB);
      GdiPBitmap := TGPBitmap.Create(Bitmap.Width, Bitmap.Height, -BytesPerScanline(Bitmap.Width, 24, 32),
        PixelFormat24bppRGB, Bitmap.ScanLine[0]);
    end else
      GdiPBitmap := TGPBitmap.Create(Bitmap.Handle, Bitmap.Palette);
    if EgdeFill or (Opacity <> 255) then
    begin
      FillMemory(@M, SizeOf(TColorMatrix), 0);
      M[0, 0] := 1;
      M[1, 1] := 1;
      M[2, 2] := 1;
      M[3, 3] := Opacity / 255;
      M[4, 4] := 1;
      Attr := TGPImageAttributes.Create;
      try
        Attr.SetColorMatrix(M);
        if EgdeFill then Attr.SetWrapMode(WrapModeTileFlipXY);
        Graphics.DrawImage(GdiPBitmap, MakeRect(ARect.Left, ARect.Top, ARect.Width, ARect.Height),
          0, 0, Bitmap.Width, Bitmap.Height, UnitPixel, Attr);
      finally
        Attr.Free;
      end;
    end else
      Graphics.DrawImage(GdiPBitmap, MakeRect(ARect.Left, ARect.Top, ARect.Width, ARect.Height));
  finally
    Graphics.Free;
    GdiPBitmap.Free;
  end;
end;


procedure PngImageAssignToBitmap(Bitmap: TBitmap; PngImage: TPngImage; IsPremultipledBitmap: Boolean = True);
var
  X, Y: Integer;
  pBitmap: PRGBAArray;
  pPng: PRGBArray;
  pPngAlpha: PByteArray;
  pPngTable: PByteArray;
  C: TRGBQuad;
  A: Byte;
begin
  if (PngImage = nil) or (PngImage.Empty) then
  begin
    Bitmap.SetSize(0, 0);
    Exit;
  end;
  if (PngImage.TransparencyMode <> ptmPartial) or (PngImage.Header.BitDepth <> 8) then
  begin
    Bitmap.Assign(PngImage);
  end else
  begin
    Bitmap.SetSize(0, 0);
    if IsPremultipledBitmap then
      Bitmap.AlphaFormat := TAlphaFormat.afPremultiplied
    else
      Bitmap.AlphaFormat := TAlphaFormat.afDefined;
    Bitmap.PixelFormat := pf32bit;
    Bitmap.SetSize(PngImage.Width, PngImage.Height);
    for Y := 0 to Bitmap.Height - 1 do
    begin
      pBitmap := Bitmap.ScanLine[Y];
      pPng := PngImage.Scanline[Y];
      pPngTable := PngImage.Scanline[Y];
      pPngAlpha := PngImage.AlphaScanline[Y];
      if PngImage.Header.ColorType = COLOR_RGBALPHA then
      // RGBA
        if IsPremultipledBitmap then
          for X := 0 to Bitmap.Width - 1 do
          begin
            pBitmap[X].rgbBlue := (pPng[x].rgbtBlue * pPngAlpha[X]) div 255;
            pBitmap[X].rgbGreen := (pPng[x].rgbtGreen * pPngAlpha[X]) div 255;
            pBitmap[X].rgbRed := (pPng[x].rgbtRed * pPngAlpha[X]) div 255;
            pBitmap[X].rgbReserved := pPngAlpha[X];
          end
        else
          for X := 0 to Bitmap.Width - 1 do
          begin
            pBitmap[X].rgbBlue := pPng[x].rgbtBlue;
            pBitmap[X].rgbGreen := pPng[x].rgbtGreen;
            pBitmap[X].rgbRed := pPng[x].rgbtRed;
            pBitmap[X].rgbReserved := pPngAlpha[X];
          end
      else if PngImage.Header.ColorType = COLOR_PALETTE then
      // PALETTE
        if IsPremultipledBitmap then
          for X := 0 to Bitmap.Width - 1 do
          begin
            C := TChunkPLTE(PngImage.Chunks.ItemFromClass(TChunkPLTE)).Item[pPngTable[X]];
            A := TChunktRNS(PngImage.Chunks.ItemFromClass(TChunktRNS)).PaletteValues[pPngTable[X]];
            pBitmap[X].rgbBlue := (C.rgbBlue * A) div 255;
            pBitmap[X].rgbGreen := (C.rgbGreen * A) div 255;
            pBitmap[X].rgbRed := (C.rgbRed * A) div 255;
            pBitmap[X].rgbReserved := A;
          end
        else
          for X := 0 to Bitmap.Width - 1 do
          begin
            C := TChunkPLTE(PngImage.Chunks.ItemFromClass(TChunkPLTE)).Item[pPngTable[X]];
            A := TChunktRNS(PngImage.Chunks.ItemFromClass(TChunktRNS)).PaletteValues[pPngTable[X]];
            pBitmap[X].rgbBlue := C.rgbBlue;
            pBitmap[X].rgbGreen := C.rgbGreen;
            pBitmap[X].rgbRed := C.rgbRed;
            pBitmap[X].rgbReserved := A;
          end
      else
      // GRAYSCALE
        if IsPremultipledBitmap then
          for X := 0 to Bitmap.Width - 1 do
          begin
            pBitmap[X].rgbBlue := (pPngTable[X] * pPngAlpha[X]) div 255;
            pBitmap[X].rgbGreen := pBitmap[X].rgbBlue;
            pBitmap[X].rgbRed := pBitmap[X].rgbBlue;
            pBitmap[X].rgbReserved := pPngAlpha[X];
          end
        else
          for X := 0 to Bitmap.Width - 1 do
          begin
            pBitmap[X].rgbBlue := pPngTable[X];;
            pBitmap[X].rgbGreen := pBitmap[X].rgbBlue;
            pBitmap[X].rgbRed := pBitmap[X].rgbBlue;
            pBitmap[X].rgbReserved := pPngAlpha[X];
          end
    end;
  end;
end;


procedure GraphicAssignToBitmap(Bitmap: TBitmap; Graphic: TGraphic); Inline;
begin
  // standart TPngImage.AssignTo works is bad!
  if Graphic is TPngImage then
    PngImageAssignToBitmap(Bitmap, TPngImage(Graphic))
  else
    Bitmap.Assign(Graphic);
end;



end.