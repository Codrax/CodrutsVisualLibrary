unit Cod.Visual.StarRate;

interface

uses
  SysUtils,
  Classes,
  Vcl.Controls,
  Cod.Components,
  Messaging,
  Types,
  Vcl.Styles,
  Vcl.Themes,
  Cod.Graphics,
  Vcl.Graphics;

type
  CStarRate = class;


  CStarRateStar = class(TMPersistent)
    private
      FColor, FBorderColor, FInaColor, FInaBorderColor: TColor;
      FBorder: boolean;
      FBorderThickness: integer;

      function Paint: boolean;

    published
      property Color : TColor read FColor write FColor stored Paint;
      property BorderColor : TColor read FBorderColor write FBorderColor stored Paint;
      property InactiveColor : TColor read FInaColor write FInaColor stored Paint;
      property InactiveBorderColor : TColor read FInaBorderColor write FInaBorderColor stored Paint;

      property Border : boolean read FBorder write FBorder stored Paint;
      property BorderThickness : integer read FBorderThickness write FBorderThickness stored Paint;
  end;

  CStarRate = class(TCustomControl)
    private
      FAuthor, FSite, FVersion: string;

      FStarsDrawn: integer;
      FRating: integer;
      FMinRating: integer;
      FMaxRating: integer;
      FSpacing: integer;
      FViewOnly: boolean;
      FStar: CStarRateStar;
      FOnChange: TNotifyEvent;
      FOnSelect: TNotifyEvent;

      mouseisdown: boolean;

      procedure SetMaxRating(const Value: integer);
      procedure SetRating(const Value: integer);
      procedure SetStars(const Value: integer);
      procedure SetSpacing(const Value: integer);

      procedure DrawStars(useinactiveset: boolean; var BitMap: TBitMap);

    procedure SetMinRating(const Value: integer);

    protected
      procedure Paint; override;

      procedure MouseDown(Button : TMouseButton; State: TShiftState; X, Y: integer); override;
      procedure MouseMove(State: TShiftState; X, Y: integer); override;
      procedure MouseUp(Button : TMouseButton; State: TShiftState; X, Y: integer); override;

    public
      constructor Create(AOwner : TComponent); override;
      destructor Destroy; override;

    published
      property OnMouseEnter;
      property OnMouseLeave;
      property OnMouseDown;
      property OnMouseUp;
      property OnMouseMove;
      property OnClick;

      property Color;
      property ParentColor;

      property ShowHint;
      property Align;
      property Anchors;
      property Cursor;
      property Visible;
      property Enabled;
      property Constraints;
      property DoubleBuffered;

      property ViewOnly : boolean read FViewOnly write FViewOnly;
      property Spacing : integer read FSpacing write SetSpacing;
      property StarDesign : CStarRateStar read FStar write FStar;
      property StarsDrawn : integer read FStarsDrawn write SetStars;
      property Rating : integer read FRating write SetRating;
      property MaximumRating : integer read FMaxRating write SetMaxRating;
      property MinimumRating : integer read FMinRating write SetMinRating;
      property OnChange: TNotifyEvent read FOnChange write FOnChange;
      property OnSelect: TNotifyEvent read FOnSelect write FOnSelect;

      property &&&Author: string Read FAuthor;
      property &&&Site: string Read FSite;
      property &&&Version: string Read FVersion;
    public
      procedure Invalidate; override;

  end;

implementation

{ CProgress }

constructor CStarRate.Create(AOwner: TComponent);
begin
  inherited;
  FAuthor                       := 'Petculescu Codrut';
  FSite                         := 'https://www.codrutsoftware.cf';
  FVersion                      := '1.1';

  FStar := CStarRateStar.Create(Self);
  with FStar do begin
    FColor := clYellow;
    FBorderColor := $0044ADFB;

    FInaColor := clGray;
    FInaBorderColor := clWindowFrame;

    FBorder := true;
    FBorderThickness := 10;
  end;

  FViewOnly := false;

  FStarsDrawn := 5;
  FRating := 0;
  FMaxRating := 10;
  FMinRating := 0;
  FSpacing := 5;

  Width := 200;
  Height := 40;
end;

destructor CStarRate.Destroy;
begin
  FreeAndNil(FStar);

  inherited;
end;

procedure CStarRate.Invalidate;
begin
  inherited;
  Paint;
end;


procedure CStarRate.MouseDown(Button: TMouseButton; State: TShiftState; X,
  Y: integer);
begin
  inherited;

  mouseisdown := true;
  MouseMove([], X, Y);
end;

procedure CStarRate.MouseMove(State: TShiftState; X, Y: integer);
var
  PreviousRating, Rate: integer;
  Changed: boolean;
begin
  inherited;

  if (not FViewOnly) and mouseisdown then
    begin
      PreviousRating := Rating;

      Rate := round(X / Width * FMaxRating);
      Changed := Rate <> Rating;
      Rating := Rate;

      if Changed and Assigned(OnSelect) then
        OnSelect(Self);

      if Rating <> PreviousRating then
        Paint;
    end;
end;

procedure CStarRate.MouseUp(Button: TMouseButton; State: TShiftState; X,
  Y: integer);
begin
  inherited;

  mouseisdown := false;
end;

procedure CStarRate.DrawStars(useinactiveset: boolean; var BitMap: TBitMap);
var
  I, size, bsize, itemw: integer;
  color, bcolor: TColor;
  Points: TArray<TPoint>;
begin
  // Create bitmap
  BitMap := TBitMap.Create;

  BitMap.Height := Height;
  BitMap.Width := Width;

  if FStar.FBorder then
    bsize := FStar.FBorderThickness
  else
    bsize := 0;

  if not useinactiveset then
    begin
      color := FStar.FColor;
      bcolor := FStar.FBorderColor;
    end
      else
        begin
          color := FStar.FInaColor;
          bcolor := FStar.FInaBorderColor;
        end;

  // Clear Canvas
  with BitMap.Canvas do
    begin
      Brush.Color := TStyleManager.ActiveStyle.GetSystemColor(Self.color);

      FillRect(cliprect);
    end;

  // Calculate Locations
  SetLength(Points, FStarsDrawn);

  itemw := round(Width / FStarsDrawn);

  size := itemw div 2 - FSpacing;

  for I := 0 to FStarsDrawn - 1 do
    begin
      Points[I].X := I * itemw + itemw div 2;
      Points[I].Y := Height div 2 - round(size * (2/3));
    end;

  // Draw Stars
  for I := 0 to FStarsDrawn - 1 do
    MakeStar(BitMap.Canvas, Points[I].X, Points[I].Y, size, color, bsize, bcolor);
end;

procedure CStarRate.Paint;
var
  workon, overlay: TBitMap;
  ActiveRect: TRect;
begin
  inherited;

  if not Visible then Exit;

  DrawStars(true, workon);
  DrawStars(false, overlay);

  // Draw
  with canvas do begin
    CopyRect(cliprect, workon.Canvas, cliprect);

    ActiveRect := cliprect;
    ActiveRect.Width := trunc(FRating / FMaxRating * ActiveRect.Width);

    CopyRect(ActiveRect, overlay.Canvas, ActiveRect);
  end;

  // Free
  workon.Free;
  overlay.Free;
end;

procedure CStarRate.SetMaxRating(const Value: integer);
begin
  FMaxRating := Value;

  if FRating > FMaxRating then
    FRating := FMaxRating;

  Paint;
end;

procedure CStarRate.SetMinRating(const Value: integer);
begin
  FMinRating := Value;

  if FRating < FMinRating then
    FRating := FMinRating;
end;

procedure CStarRate.SetRating(const Value: integer);
begin
  if (Value <= FMaxRating)
    and (Value >= FMinRating)
      and (Value <> FRating) then
        begin
          FRating := Value;
          if Assigned(OnChange) then
            OnChange(Self);
        end;

  Paint;
end;

procedure CStarRate.SetSpacing(const Value: integer);
begin
  FSpacing := Value;

  Paint;
end;

procedure CStarRate.SetStars(const Value: integer);
begin
  if Value > 0 then
    FStarsDrawn := Value;

  Paint;
end;

{ CStarRateStar }

function CStarRateStar.Paint: boolean;
begin
  if Self.Owner is CStarRate then begin
    CStarRate(Self.Owner).Paint;
    Result := True;
  end else Result := False;
end;

end.

