﻿unit Cod.Visual.StandardIcons;

interface

uses
  SysUtils,
  Classes,
  Vcl.Controls,
  Vcl.Graphics,
  Cod.Components,
  Messaging,
  Types,
  Vcl.Styles,
  Cod.VarHelpers,
  Vcl.Themes,
  Windows;

type
  CStandardIcon = class;
  CodIconType = (ciconCheckmark, ciconError, ciconStop, ciconQuestion, ciconInformation, ciconWarning, ciconStar, ciconNone);

  TPent = array[0..4] of TPoint;

  CStandardIcon = class(TCustomTransparentControl)
      constructor Create(AOwner : TComponent); override;
      destructor Destroy; override;
    private
      FAuthor, FSite, FVersion: string;
      FIcon : CodIconType;
      FProport: boolean;
      FWidth: integer;
    procedure SetIcon(const Value: CodIconType);
    procedure SetProport(const Value: boolean);
    procedure SetWid(const Value: integer);

    class procedure DrawPentacle(Canvas : TCanvas; Pent : TPent);
    class function MakePent(X, Y, L : integer) : TPent;
    class procedure MakeStar(Canvas : TCanvas; cX, cY, size : integer; Colour :TColor; bordersize: integer; bordercolor: TColor);
    protected
      procedure Paint; override;
    published
      property OnMouseEnter;
      property OnMouseLeave;
      property OnMouseDown;
      property OnMouseUp;
      property OnMouseMove;
      property OnClick;

      property Color;
      property ParentColor;
      property ParentBackground;

      property ShowHint;
      property Align;
      property Anchors;
      property Cursor;
      property Visible;
      property Enabled;
      property Constraints;
      property DoubleBuffered;

      property Proportional : boolean read FProport write SetProport;
      property SelectedIcon : CodIconType read FIcon write SetIcon;
      property PenWidth : integer read FWidth write SetWid;

      property &&&Author: string Read FAuthor;
      property &&&Site: string Read FSite;
      property &&&Version: string Read FVersion;
    public
      procedure Invalidate; override;
  end;

implementation

{ CProgress }

constructor CStandardIcon.Create(AOwner: TComponent);
begin
  inherited;
  FAuthor                       := 'Petculescu Codrut';
  FSite                         := 'https://www.codrutsoftware.cf';
  FVersion                      := '1.1';

  interceptmouse:=True;

  FProport := true;
  FIcon := ciconCheckMark;
  FWidth := 10;

  Width := 60;
  Height := 60;
end;

destructor CStandardIcon.Destroy;
begin

  inherited;
end;

procedure CStandardIcon.Invalidate;
begin
  inherited;
  Paint;
end;

class procedure CStandardIcon.MakeStar(Canvas : TCanvas; cX, cY, size : integer; Colour :TColor; bordersize: integer; bordercolor: TColor);
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

class function CStandardIcon.MakePent(X, Y, L : integer) : TPent;
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

class procedure CStandardIcon.DrawPentacle(Canvas : TCanvas; Pent : TPent);
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

procedure CStandardIcon.Paint;
var
  s, Quater: integer;
  Text: string;
  R: TRect;
begin
  inherited;
  if FProport then begin
    if width < height then
      height := width
    else
      width := height;
  end;

  if not Visible then Exit;

  // Draw
  with canvas do begin
    // Transparent
    if NOT ParentBackground then
    begin
      Brush.Color := TStyleManager.ActiveStyle.GetSystemColor(Self.Color);
      FillRect(cliprect);
    end;

    // Icon Selector
    case FIcon of
      CodIconType.ciconCheckmark: begin
        pen.Color := 1505536;
        brush.Color := 59648;
        pen.Width := (FWidth * width) div 100;
        Ellipse(Pen.Width div 2, Pen.Width div 2, width - Pen.Width div 2, height - Pen.Width div 2);

        pen.Width := 10;
        pen.Color := clWhite;

        pen.Width := (FWidth * width) div 100;

        moveto( trunc(clientwidth / 4.9), trunc(clientheight / 1.9) );
        lineto( trunc(clientwidth / 2.5), trunc(clientheight / 1.4) );
        lineto( trunc(clientwidth / 1.35), trunc(clientheight / 3.6) );
      end;
      CodIconType.ciconError: begin
        pen.Color := 196741;
        brush.Color := 2363135;
        pen.Width := (FWidth * width) div 100;
        Ellipse(Pen.Width div 2, Pen.Width div 2, width - Pen.Width div 2, height - Pen.Width div 2);

        pen.Width := 10;
        pen.Color := clWhite;

        pen.Width := (FWidth * width) div 100;

        moveto( trunc(clientwidth / 3), trunc(clientheight / 3) );
        lineto( clientwidth - trunc(clientwidth / 3), clientheight - trunc(clientheight / 3) );

        moveto( clientwidth - trunc(clientwidth / 3), trunc(clientheight / 3) );
        lineto( trunc(clientwidth / 3), clientheight - trunc(clientheight / 3) );
      end;
      CodIconType.ciconInformation: begin
        pen.Color := 16716032;
        brush.Color := 16727571;
        pen.Width := (FWidth * width) div 100;
        Ellipse(Pen.Width div 2, Pen.Width div 2, width - Pen.Width div 2, height - Pen.Width div 2);

        pen.Width := 10;
        pen.Color := clWhite;

        font.Style := [fsBold];
        font.Name := 'Segoe UI';
        font.Color := clWhite;
        if clientwidth < clientheight then
          s := clientwidth
        else
          s := clientheight;
        Font.Size := trunc(s / 1.8);

        Brush.Style := bsClear;
        TextOut( (Width div 2) - ( TextWidth('i') div 2 ) , (Height div 2) - ( TextHeight('i') div 2 ) , 'i');
      end;
      CodIconType.ciconQuestion: begin
        pen.Color := 16716032;
        brush.Color := 16727571;
        pen.Width := (FWidth * width) div 100;
        Ellipse(Pen.Width div 2, Pen.Width div 2, width - Pen.Width div 2, height - Pen.Width div 2);

        pen.Width := 10;
        pen.Color := clWhite;

        font.Style := [fsBold];
        font.Name := 'Segoe UI';
        font.Color := clWhite;
        if clientwidth < clientheight then
          s := clientwidth
        else
          s := clientheight;
        Font.Size := trunc(s / 1.8);

        Brush.Style := bsClear;
        TextOut( (Width div 2) - ( TextWidth('?') div 2 ) , (Height div 2) - ( TextHeight('?') div 2 ) , '?');
      end;
      CodIconType.ciconWarning: begin
        pen.Color := clBlack;
        brush.Color := 63231;
        pen.Width := (FWidth * width) div 100;
        Self.Canvas.Polygon( [
          Point(clientwidth div 2,Pen.Width div 2),
          Point(Pen.Width div 2, clientheight - Pen.Width div 2),
          Point(clientwidth - Pen.Width div 2, clientheight - Pen.Width div 2)
        ]);

        pen.Width := 10;
        pen.Color := clWhite;

        font.Style := [fsBold];
        font.Name := 'Segoe UI';
        font.Color := clBlack;
        if clientwidth < clientheight then
          s := clientwidth
        else
          s := clientheight;
        Font.Size := trunc(s / 2.4);

        Brush.Style := bsClear;
        TextOut( (Width div 2) - ( TextWidth('!') div 2 ) , trunc(Height / 1.7) - ( TextHeight('!') div 2 ) , '!');
      end;
      CodIconType.ciconStop: begin
        pen.Color := 196741;
        brush.Color := 2363135;
        pen.Width := (FWidth * width) div 100;

        Quater := Width div 4;

        Self.Canvas.Polygon( [
          Point(Quater, pen.Width div 2),
          Point(Quater * 3, pen.Width div 2),
          Point(Width - pen.Width div 2, Quater),
          Point(Width - pen.Width div 2, Quater * 3),
          Point(Quater * 3, Height - pen.Width div 2),
          Point(Quater, Height - pen.Width div 2),
          Point(pen.Width div 2, Quater * 3),
          Point(pen.Width div 2, Quater)
        ]);

        pen.Width := 10;
        pen.Color := clWhite;

        font.Style := [fsBold];
        font.Name := 'Impact';
        font.Color := clWhite;
        if clientwidth < clientheight then
          s := clientwidth
        else
          s := clientheight;
        Font.Size := trunc(s / 3.6);
        Font.Style := [fsBold];

        Brush.Style := bsClear;

        Text := 'STOP';
        R := Rect(0, Height div 2 - TextHeight(Text) div 2, Width, Height);;


        Canvas.TextRect(R, Text, [tfCenter]);
      end;
      CodIconType.ciconStar: begin
        MakeStar(Canvas, width div 2, height div 15, trunc(width / 1.75), clYellow, height div 20, $0001BAF8);
      end;
    end;
  end;
end;

procedure CStandardIcon.SetIcon(const Value: CodIconType);
var
  nediv: boolean;
begin
  nediv := false;

  if (value = ciconWarning) and (FIcon <> ciconWarning) then nediv := true;
  if (value <> ciconWarning) and (FIcon = ciconWarning) then nediv := true;

  if (value = ciconStar) and (FIcon <> ciconStar) then nediv := true;
  if (value <> ciconStar) and (FIcon = ciconStar) then nediv := true;

  if (value = ciconNone) and (FIcon <> ciconNone) then nediv := true;
  if (value <> ciconNone) and (FIcon = ciconNone) then nediv := true;


  FIcon := Value;

  Paint;
  if nediv then
    Repaint
end;

procedure CStandardIcon.SetProport(const Value: boolean);
begin
  FProport := Value;
  Paint;
end;

procedure CStandardIcon.SetWid(const Value: integer);
begin
  FWidth := Value;
  Paint;
end;

end.

