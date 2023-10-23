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
{$SCOPEDENUMS ON}

interface
  uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Dialogs, Math, Winapi.GDIPOBJ,
  Winapi.GDIPAPI;

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

  // HBS
  function HSBtoColor(hue, sat, bri: Double): TColor;

  // Extra Utilities
  function GetHBSCircleColor(Degree: integer): TColor;

  // Fix OutOfRange colors
  (* Singe Delphi 11.4, the RangeCheckError flag is enabled on new projects,
  this affects color functions that reqire a DWORD and the default system
  TColors from the Windows units, are invalid. To fix  them, use ColorToRGB *)

  // Color alteration
  function ChangeColorSat(BaseColor: TColor; ByValue: integer): TColor;
  function ColorToGrayScale(BaseColor: TColor; ToneDown: integer = 3): TColor;
  function ColorBlend(Color1, Color2: TColor; A: Byte): TColor;
  function RandomLightColor(minimumlightness: byte): TColor;
  function RandomDarkColor(maximumlightness: byte): TColor;
  function RandomColor(min, max: byte): TColor;
  function InvertColor(Color: TColor): TColor;

  // Calculations
  function GetColorSat(BaseColor: CRGBA; ColorSize: integer = 255): integer; overload;
  function GetColorSat(BaseColor: TColor; ColorSize: integer = 255): integer; overload;

  // Extras
  function FontColorForBackground(bgcolor: TColor): TColor;

  type
    CColors = record
    const
    Aliceblue = TColor($FFF8F0);
    Antiquewhite = TColor($D7EBFA);
    Aqua = TColor($FFFF00);
    Aquamarine = TColor($D4FF7F);
    Azure = TColor($FFFFF0);
    Beige = TColor($DCF5F5);
    Bisque = TColor($C4E4FF);
    Black = TColor($000000);
    Blanchedalmond = TColor($CDEBFF);
    Blue = TColor($FF0000);
    Blueviolet = TColor($E22B8A);
    Brown = TColor($2A2AA5);
    Burlywood = TColor($87B8DE);
    Cadetblue = TColor($A09E5F);
    Chartreuse = TColor($00FF7F);
    Chocolate = TColor($1E69D2);
    Coral = TColor($507FFF);
    Cornflowerblue = TColor($ED9564);
    Cornsilk = TColor($DCF8FF);
    Crimson = TColor($3C14DC);
    Cyan = TColor($FFFF00);
    Darkblue = TColor($8B0000);
    Darkcyan = TColor($8B8B00);
    Darkgoldenrod = TColor($0B86B8);
    Darkgray = TColor($A9A9A9);
    Darkgreen = TColor($006400);
    Darkgrey = TColor($A9A9A9);
    Darkkhaki = TColor($6BB7BD);
    Darkmagenta = TColor($8B008B);
    Darkolivegreen = TColor($2F6B55);
    Darkorange = TColor($008CFF);
    Darkorchid = TColor($CC3299);
    Darkred = TColor($00008B);
    Darksalmon = TColor($7A96E9);
    Darkseagreen = TColor($8FBC8F);
    Darkslateblue = TColor($8B3D48);
    Darkslategray = TColor($4F4F2F);
    Darkslategrey = TColor($4F4F2F);
    Darkturquoise = TColor($D1CE00);
    Darkviolet = TColor($D30094);
    Deeppink = TColor($9314FF);
    Deepskyblue = TColor($FFBF00);
    Dimgray = TColor($696969);
    Dimgrey = TColor($696969);
    Dodgerblue = TColor($FF901E);
    Firebrick = TColor($2222B2);
    Floralwhite = TColor($F0FAFF);
    Forestgreen = TColor($228B22);
    Fuchsia = TColor($FF00FF);
    Gainsboro = TColor($DCDCDC);
    Ghostwhite = TColor($FFF8F8);
    Gold = TColor($00D7FF);
    Goldenrod = TColor($20A5DA);
    Gray = TColor($808080);
    Green = TColor($008000);
    Greenyellow = TColor($2FFFAD);
    Grey = TColor($808080);
    Honeydew = TColor($F0FFF0);
    Hotpink = TColor($B469FF);
    Indianred = TColor($5C5CCD);
    Indigo = TColor($82004B);
    Ivory = TColor($F0FFFF);
    Khaki = TColor($8CE6F0);
    Lavender = TColor($FAE6E6);
    Lavenderblush = TColor($F5F0FF);
    Lawngreen = TColor($00FC7C);
    Lemonchiffon = TColor($CDFAFF);
    Lightblue = TColor($E6D8AD);
    Lightcoral = TColor($8080F0);
    Lightcyan = TColor($FFFFE0);
    Lightgoldenrodyellow = TColor($D2FAFA);
    Lightgray = TColor($D3D3D3);
    Lightgreen = TColor($90EE90);
    Lightgrey = TColor($D3D3D3);
    Lightpink = TColor($C1B6FF);
    Lightsalmon = TColor($7AA0FF);
    Lightseagreen = TColor($AAB220);
    Lightskyblue = TColor($FACE87);
    Lightslategray = TColor($998877);
    Lightslategrey = TColor($998877);
    Lightsteelblue = TColor($DEC4B0);
    Lightyellow = TColor($E0FFFF);
    LtGray = TColor($C0C0C0);
    MedGray = TColor($A4A0A0);
    DkGray = TColor($808080);
    MoneyGreen = TColor($C0DCC0);
    LegacySkyBlue = TColor($F0CAA6);
    Cream = TColor($F0FBFF);
    Lime = TColor($00FF00);
    Limegreen = TColor($32CD32);
    Linen = TColor($E6F0FA);
    Magenta = TColor($FF00FF);
    Maroon = TColor($000080);
    Mediumaquamarine = TColor($AACD66);
    Mediumblue = TColor($CD0000);
    Mediumorchid = TColor($D355BA);
    Mediumpurple = TColor($DB7093);
    Mediumseagreen = TColor($71B33C);
    Mediumslateblue = TColor($EE687B);
    Mediumspringgreen = TColor($9AFA00);
    Mediumturquoise = TColor($CCD148);
    Mediumvioletred = TColor($8515C7);
    Midnightblue = TColor($701919);
    Mintcream = TColor($FAFFF5);
    Mistyrose = TColor($E1E4FF);
    Moccasin = TColor($B5E4FF);
    Navajowhite = TColor($ADDEFF);
    Navy = TColor($800000);
    Oldlace = TColor($E6F5FD);
    Olive = TColor($008080);
    Olivedrab = TColor($238E6B);
    Orange = TColor($00A5FF);
    Orangered = TColor($0045FF);
    Orchid = TColor($D670DA);
    Palegoldenrod = TColor($AAE8EE);
    Palegreen = TColor($98FB98);
    Paleturquoise = TColor($EEEEAF);
    Palevioletred = TColor($9370DB);
    Papayawhip = TColor($D5EFFF);
    Peachpuff = TColor($B9DAFF);
    Peru = TColor($3F85CD);
    Pink = TColor($CBC0FF);
    Plum = TColor($DDA0DD);
    Powderblue = TColor($E6E0B0);
    Purple = TColor($800080);
    Red = TColor($0000FF);
    Rosybrown = TColor($8F8FBC);
    Royalblue = TColor($E16941);
    Saddlebrown = TColor($13458B);
    Salmon = TColor($7280FA);
    Sandybrown = TColor($60A4F4);
    Seagreen = TColor($578B2E);
    Seashell = TColor($EEF5FF);
    Sienna = TColor($2D52A0);
    Silver = TColor($C0C0C0);
    Skyblue = TColor($EBCE87);
    Slateblue = TColor($CD5A6A);
    Slategray = TColor($908070);
    Slategrey = TColor($908070);
    Snow = TColor($FAFAFF);
    Springgreen = TColor($7FFF00);
    Steelblue = TColor($B48246);
    Tan = TColor($8CB4D2);
    Teal = TColor($808000);
    Thistle = TColor($D8BFD8);
    Tomato = TColor($4763FF);
    Turquoise = TColor($D0E040);
    Violet = TColor($EE82EE);
    Wheat = TColor($B3DEF5);
    White = TColor($FFFFFF);
    Whitesmoke = TColor($F5F5F5);
    Yellow = TColor($00FFFF);
    Yellowgreen = TColor($32CD9A);
    Null = TColor($00000000);
    end;

implementation

{ ColorTools }

function GetColorSat(BaseColor: CRGBA; ColorSize: integer): integer;
var
  l1, l2, l3: real;
begin
  l1 := BaseColor.R / 255 * ColorSize;
  l2 := BaseColor.G / 255 * ColorSize;
  l3 := BaseColor.B / 255 * ColorSize;

  Result := trunc((l1 + l2 + l3)/3);
end;

function GetColorSat(BaseColor: TColor; ColorSize: integer): integer;
begin
  Result := GetColorSat(GetRGB(BaseColor), ColorSize);
end;

function ChangeColorSat(BaseColor: TColor; ByValue: integer): TColor;
var
  RBGval: longint;
  R, G, B: integer;
begin
  RBGval := ColorToRGB(BaseColor);
  R := GetRValue(RBGval);
  G := GetGValue(RBGval);
  B := GetBValue(RBGval);

  R := R + ByValue;
  G := G + ByValue;
  B := B + ByValue;

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
  RGB1, RGB2: CRGB;
  R, G, B: Byte;
begin
  RGB1.FromColor(Color1);
  RGB2.FromColor(Color2);

  R := RGB1.R + (RGB2.R - RGB1.R) * A div 255;
  G := RGB1.G + (RGB2.G - RGB1.G) * A div 255;
  B := RGB1.B + (RGB2.B - RGB1.B) * A div 255;

  Result := RGB(R, G, B);
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

function InvertColor(Color: TColor): TColor;
var
  R, G, B: integer;
begin
  R := 255 - GetRValue(Color);
  G := 255 - GetGValue(Color);
  B := 255 - GetBValue(Color);
  Result := RGB(R, G, B);
end;
function FontColorForBackground(bgcolor: TColor): TColor;
begin
  if GetColorSat(bgcolor, 100) < 65 then
    Result := clWhite
  else
    Result := clBlack;
end;

function ColorToGrayScale(BaseColor: TColor; ToneDown: integer): TColor;
var
  RBGval: longint;
  R, G, B: integer;
begin
  RBGval := ColorToRGB(BaseColor);
  R := GetRValue(RBGval);
  G := GetGValue(RBGval);
  B := GetBValue(RBGval);

  R:= (R+G+B) div ToneDown;
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


function HSBtoColor(hue, sat, bri: Double): TColor;
var
  f, h: Double;
  u, p, q, t: Byte;
begin
  u := Trunc(bri * 255 + 0.5);
  if sat = 0 then
    Exit(rgb(u, u, u));

  h := (hue - Floor(hue)) * 6;
  f := h - Floor(h);
  p := Trunc(bri * (1 - sat) * 255 + 0.5);
  q := Trunc(bri * (1 - sat * f) * 255 + 0.5);
  t := Trunc(bri * (1 - sat * (1 - f)) * 255 + 0.5);

  case Trunc(h) of
    0:
      result := rgb(u, t, p);
    1:
      result := rgb(q, u, p);
    2:
      result := rgb(p, u, t);
    3:
      result := rgb(p, q, u);
    4:
      result := rgb(t, p, u);
    5:
      result := rgb(u, p, q);
  else
    result := clwhite;
  end;
end;

function GetHBSCircleColor(Degree: integer): TColor;
begin
  Result := HSBtoColor( Degree / 360 * 1, 1, 1 );
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