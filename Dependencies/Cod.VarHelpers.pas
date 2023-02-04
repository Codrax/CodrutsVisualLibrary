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
  VCL.Graphics, Winapi.ActiveX, URLMon, IOUtils, System.Generics.Collections,
  Cod.ColorUtils, System.Generics.Defaults, Vcl.Imaging.pngimage,
  WinApi.GdipObj, WinApi.GdipApi, Win.Registry, Cod.GDI, Cod.Types;

  type
    // Color Helper
    TColorHelper = record helper for TColor
    public
      function ToString: string; overload; inline;
      function ToInteger: integer; overload; inline;
      function ToRGB: CRGB; overload; inline;
    end;

    // TArray colection
    TArrayUtils<T> = class
    public
      class function Contains(const x : T; const anArray : array of T) : boolean;
      class function GetIndex(const x : T; const anArray : array of T) : integer;
    end;

    // TArray generic types
    TArrayArrayHelper = record helper for TArray<TArray>
    public
      function Count: integer; overload; inline;
      procedure SetToLength(ALength: integer);
    end;

    TStringArrayHelper = record helper for TArray<string>
    public
      function Count: integer; overload; inline;
      procedure SetToLength(ALength: integer);
    end;

    TIntegerArrayHelper = record helper for TArray<integer>
    public
      function Count: integer; overload; inline;
      procedure SetToLength(ALength: integer);
    end;

    TRealArrayHelper = record helper for TArray<real>
    public
      function Count: integer; overload; inline;
      procedure SetToLength(ALength: integer);
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

      procedure GDITint(Rectangle: TRect; Color: TColor; Opacity: byte = 75);
      procedure GDIRectangle(Rectangle: TRect; Brush: TGDIBrush; Pen: TGDIPen);
      procedure GDIRoundRect(RoundRect: TRoundRect; Brush: TGDIBrush; Pen: TGDIPen);
      procedure GDICircle(Rectangle: TRect; Brush: TGDIBrush; Pen: TGDIPen);
      procedure GDIPolygon(Points: TArray<TPoint>; Brush: TGDIBrush; Pen: TGDIPen);
      procedure GDILine(Line: TLine; Pen: TGDIPen);
      procedure GDIGraphic(Graphic: TGraphic; Rect: TRect);
    end;

    // Registry
    TRegHelper = class helper for TRegistry
      procedure RenameKey(const OldName, NewName: string);
      procedure CloneKey(const KeyName: string);

      procedure MoveKeyTo(const OldName, NewKeyPath: string; Delete: Boolean);
    end;

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

// TArray Generic Helpers

function TArrayArrayHelper.Count: integer;
begin
  Result := length(Self);
end;

function TStringArrayHelper.Count: integer;
begin
  Result := length(Self);
end;

function TIntegerArrayHelper.Count: integer;
begin
  Result := length(Self);
end;

function TRealArrayHelper.Count: integer;
begin
  Result := length(Self);
end;

procedure TArrayArrayHelper.SetToLength(ALength: integer);
begin
  SetLength(Self, ALength);
end;

procedure TStringArrayHelper.SetToLength(ALength: integer);
begin
  SetLength(Self, ALength);
end;

procedure TIntegerArrayHelper.SetToLength(ALength: integer);
begin
  SetLength(Self, ALength);
end;

procedure TRealArrayHelper.SetToLength(ALength: integer);
begin
  SetLength(Self, ALength);
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
  DrawGraphic(Self, Graphic, Rect);
end;

{ TRegHelper }
procedure TRegHelper.RenameKey(const OldName, NewName: string);
begin
  Self.MoveKey(OldName, NewName, true);
end;

procedure TRegHelper.CloneKey(const KeyName: string);
var
  CloneNumber: integer;
begin
  CloneNumber := 1;
  repeat
    inc(CloneNumber);
  until not Self.KeyExists(KeyName + '(' + inttostr( CloneNumber ) + ')');

  MoveKey(KeyName, KeyName + '(' + inttostr( CloneNumber ) + ')', false);
end;

procedure TRegHelper.MoveKeyTo(const OldName, NewKeyPath: string; Delete: Boolean);
var
  RegistryOld,
  RegistryNew: TRegistry;

  I: integer;

  ValueNames: TStringList;
  KeyNames: TStringList;

  procedure MoveValue(SrcKey, DestKey: HKEY; const Name: string);
  var
    Len: Integer;
    OldKey, PrevKey: HKEY;
    Buffer: PChar;
    RegData: TRegDataType;
  begin
    OldKey := CurrentKey;
    SetCurrentKey(SrcKey);
    try
      Len := GetDataSize(Name);
      if Len >= 0 then
      begin
        Buffer := AllocMem(Len);
        try
          Len := GetData(Name, Buffer, Len, RegData);
          PrevKey := CurrentKey;
          SetCurrentKey(DestKey);
          try
            PutData(Name, Buffer, Len, RegData);
          finally
            SetCurrentKey(PrevKey);
          end;
        finally
          FreeMem(Buffer);
        end;
      end;
    finally
      SetCurrentKey(OldKey);
    end;
  end;
begin
  /// Attention!
  /// The NewKeyPath requires a registry path in the same HIVE. This NEEDS to be a
  /// path in the HIVE, only giving the new Key Name will create a new Key in the
  /// root of the HIVE!

  ValueNames := TStringList.Create;
  KeyNames := TStringList.Create;

  RegistryNew := TRegistry.Create( Self.Access );
  RegistryOld := TRegistry.Create( Self.Access );
  try
    // Open Keys
    RegistryOld.OpenKey( IncludeTrailingPathDelimiter( Self.CurrentPath + OldName ), false );
    RegistryNew.OpenKey( IncludeTrailingPathDelimiter( NewKeyPath ), True );

    // Index Keys/Values
    RegistryOld.GetValueNames(ValueNames);
    RegistryOld.GetKeyNames(KeyNames);

    // Copy Values
    for I := 1 to ValueNames.Count do
      MoveValue( RegistryOld.CurrentKey, RegistryNew.CurrentKey,
                 ValueNames[I - 1] );

    // Copy subkeys
    for I := 1 to KeyNames.Count do
      RegistryOld.MoveKeyTo(KeyNames[I - 1],
                            RegistryNew.CurrentPath + KeyNames[I - 1] + '\',
                            false);
  finally
    // Free Mem
    RegistryOld.Free;
    RegistryNew.Free;

    ValueNames.Free;
    KeyNames.Free;

    if Delete then
      Self.DeleteKey(OldName);
  end;
end;

end.