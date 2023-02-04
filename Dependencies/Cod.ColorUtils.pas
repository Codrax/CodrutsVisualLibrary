{***********************************************************}
{                  Codruts Color Utilities                  }
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

unit Cod.ColorUtils;

interface
  uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Dialogs, Math, GDIPOBJ,
  GDIPAPI;

  type
    CRGBA = record
    public
      R, G, B, A: byte;

      function Create(Red, Green, Blue: Byte; Alpha: Byte = 255): CRGBA;

      function MakeGDIBrush: TGPSolidBrush;
      function MakeGDIPen(Width: Single = 1): TGPPen;

      function ToColor(Alpha: Byte = 255): TColor;
      procedure FromColor(Color: TColor; Alpha: Byte = 255);
    end;

  CRGB = CRGBA;

  // Color Conversion
  function GetRGB(Color: TColor; Alpha: Byte = 255): CRGBA; overload;
  function GetRGB(R, G, B: Byte; Alpha: Byte = 255): CRGBA; overload;
  function GetColor(Color: CRGBA): TColor;

  // HEX
  function ColorToHEX(Color: TColor): string;
  function HEXToColor(HEX: string): TColor;

  // Color alteration
  function ChangeColorSat(clr: TColor; perc: integer): TColor;
  function ColorToGrayScale(clr: TColor; by: integer = 3): TColor;
  function ColorBlend(Color1, Color2: TColor; A: Byte): TColor;
  function RandomLightColor(minimumlightness: byte): TColor;
  function RandomDarkColor(maximumlightness: byte): TColor;
  function RandomColor(min, max: byte): TColor;

  // Calculations
  function GetColorSat(color: CRGBA; ofing: integer = 255): integer; overload;
  function GetColorSat(color: TColor; ofing: integer = 255): integer; overload;

  // Extras
  function FontColorForBackground(bgcolor: TColor): TColor;

implementation


{ ColorTools }

function GetColorSat(color: CRGBA; ofing: integer): integer;
var
  l1, l2, l3: real;
begin
  l1 := color.R / 255 * ofing;
  l2 := color.G / 255 * ofing;
  l3 := color.B / 255 * ofing;

  Result := trunc((l1 + l2 + l3)/3);
end;

function GetColorSat(color: TColor; ofing: integer): integer;
begin
  Result := GetColorSat(GetRGB(color), ofing);
end;

function ChangeColorSat(clr: TColor; perc: integer): TColor;
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

function ColorBlend(Color1, Color2: TColor; A: Byte): TColor;
var
  c1, c2: LongInt;
  r, g, b, v1, v2: byte;
begin
  A:= Round(2.55 * A);
  c1 := ColorToRGB(Color1);
  c2 := ColorToRGB(Color2);
  v1:= Byte(c1);
  v2:= Byte(c2);
  r:= A * (v1 - v2) shr 8 + v2;
  v1:= Byte(c1 shr 8);
  v2:= Byte(c2 shr 8);
  g:= A * (v1 - v2) shr 8 + v2;
  v1:= Byte(c1 shr 16);
  v2:= Byte(c2 shr 16);
  b:= A * (v1 - v2) shr 8 + v2;
  Result := (b shl 16) + (g shl 8) + r;
end;

function RandomLightColor(minimumlightness: byte): TColor;
begin
  Result := rgb(minimumlightness+round(random*(255 - minimumlightness)),
            minimumlightness+round(random*(255 - minimumlightness)),
            minimumlightness+round(random*(255 - minimumlightness)))
end;

function RandomDarkColor(maximumlightness: byte): TColor;
begin
  Result := rgb(round(random*(maximumlightness)),
            round(random*(maximumlightness)),
            round(random*(maximumlightness)))
end;

function RandomColor(min, max: byte): TColor;
begin
  Result := rgb(randomrange(min, max),
            randomrange(min, max),
            randomrange(min, max))
end;

function FontColorForBackground(bgcolor: TColor): TColor;
begin
  if GetColorSat(bgcolor, 100) < 65 then
    Result := clWhite
  else
    Result := clBlack;
end;

function ColorToGrayScale(clr: TColor; by: integer): TColor;
var
  RBGval: longint;
  R, G, B: integer;
begin
  RBGval := ColorToRGB(clr);
  R := GetRValue(RBGval);
  G := GetGValue(RBGval);
  B := GetBValue(RBGval);

  R:= (R+G+B) div by;
  G:= R; B:=R;

  Result := RGB(r,g,b);
end;

function ColorToHEX(Color: TColor): string;
begin
  Result := '#' +
    IntToHex( GetRValue( Color ), 2 ) +
    IntToHex( GetGValue( Color ), 2 ) +
    IntToHex( GetBValue( Color ), 2 );
end;

function GetColor(Color: CRGBA): TColor;
begin
  Result := RGB(Color.R, Color.G, Color.B);
end;

function GetRGB(Color: TColor; Alpha: Byte): CRGBA;
begin
  Result.FromColor(Color, Alpha);
end;

function GetRGB(R, G, B: Byte; Alpha: Byte): CRGBA;
begin
  Result.Create(R, G, B, Alpha);
end;

function HEXToColor(HEX: string): TColor;
begin
  HEX := HEX.Replace('#', '');
  try
  Result :=
    RGB(
      StrToInt( '$'+Copy( HEX, 1, 2 ) ),
      StrToInt( '$'+Copy( HEX, 3, 2 ) ),
      StrToInt( '$'+Copy( HEX, 5, 2 ) )
    );
  except
    Result := 0;
  end;
end;

{ CRGB }

function CRGBA.Create(Red, Green, Blue, Alpha: Byte): CRGBA;
begin
  R := Red;
  G := Green;
  B := Blue;

  A := Alpha;

  Result := Self;
end;

procedure CRGBA.FromColor(Color: TColor; Alpha: Byte);
var
  RBGval: longint;
begin
  RBGval := ColorToRGB(Color);

  try
    R := GetRValue(RBGval);
    G := GetGValue(RBGval);
    B := GetBValue(RBGval);

    A := Alpha;
  finally

  end;
end;

function CRGBA.MakeGDIBrush: TGPSolidBrush;
begin
  Result := TGPSolidBrush.Create( MakeColor(A, R, G, B) );
end;

function CRGBA.MakeGDIPen(Width: Single): TGPPen;
begin
  Result := TGPPen.Create( MakeColor(A, R, G, B), Width );
end;

function CRGBA.ToColor(Alpha: Byte): TColor;
begin
    Result := RGB(R, G, B);

    A := Alpha;
end;

end.