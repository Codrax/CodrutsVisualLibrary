unit Cod.Labels;

interface

uses
  SysUtils,
  Classes,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ExtCtrls,
  MetroTools;

type

  CLabelHorizontalAllign = (chalLeft, chalRight, chalCenter);
  CLabelVerticalAllign = (cvalLeft, cvalRight, cvalCenter);

  CCodFont = class(TMPersistent)
    private
      FFName: TFontName;
      FFSize,
      FFOrientation: integer;
      FFColor: TColor;
      FFStyle: TFontStyles;
      FSolidback: boolean;
    published
      property FontName: TFontName read FFName write FFName;
      property Size: integer read FFSize write FFSize;
      property Orientation: integer read FFOrientation write FFOrientation;
      property Color: TColor read FFColor write FFColor;
      property Style: TFontStyles read FFStyle write FFStyle;
      property SolidBack: boolean read FSolidback write FSolidback;
  end;

  CCustomAlign = class(TMPersistent)
    private
      FEnablCAlign: boolean;
      FCaX,
      FCaY: integer;
    published
      property Enable : boolean read FEnablCAlign write FEnablCAlign;
      property CustomX : integer read FCaX write FCaX;
      property CustomY : integer read FCaY write FCaY;
  end;

  CLabel = class(TCustomTransparentControl)
      constructor Create(AOwner : TComponent); override;
      destructor Destroy; override;
    private
      FAuthor, FSite, FVersion: string;
      FText: string;
      FFont : CCodFont;
      FCAlign : CCustomAlign;
      FVertAlign : CLabelVerticalAllign;
      FHorzAlign : CLabelHorizontalAllign;
      FPropFont: boolean;
    procedure SetText(const Value: string);
    protected
      procedure Paint; override;
    published
      property OnMouseEnter;
      property OnMouseLeave;
      property OnMouseDown;
      property OnMouseUp;
      property OnMouseMove;
      property OnClick;

      property ShowHint;
      property Align;
      property Anchors;
      property Cursor;
      property Visible;
      property Enabled;
      property Constraints;
      property DoubleBuffered;

      property ProportionalFont: boolean read FPropFont write FPropFont;
      property AllignCustomized : CCustomAlign read FCAlign write FCAlign;
      property AlignVertival : CLabelVerticalAllign read FVertAlign write FVertAlign;
      property AlignHorizontal : CLabelHorizontalAllign read FHorzAlign write FHorzAlign;
      property Font : CCodFont read FFont write FFont;
      property Text : string read FText write SetText;

      property &&&Author: string Read FAuthor;
      property &&&Site: string Read FSite;
      property &&&Version: string Read FVersion;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Codrut Components',[CLabel]);
end;


{ CProgress }

constructor CLabel.Create(AOwner: TComponent);
begin
  inherited;
  FAuthor                       := 'Petculescu Codrut';
  FSite                         := 'https://www.codrutsoftware.cf';
  FVersion                      := '0.1';

  interceptmouse:=True;

  FFont := CCodFont.Create;
  with FFOnt do begin
    FFName := 'Segoe UI';
    FFSize := 10;
    FFOrientation := 0;
    FFColor := clBlack;
    FSolidback := false;
  end;

  FCAlign := CCustomAlign.Create;
  with FCAlign do begin
    FEnablCAlign := false;
    FCaX := 0;
    FCaY := 0;
  end;

  FText := 'Hello World!';

  Width := 50;
  Height := 20;
end;

destructor CLabel.Destroy;
begin
  FreeAndNil(FFont);
  FreeAndNil(AllignCustomized);
  inherited;
end;


procedure CLabel.Paint;
begin
  inherited;
  with canvas do begin
    if NOT FFont.FSolidback then Brush.Style := bsClear else Brush.Style := bsSolid;
    
    TextOut(10,10,FText);
  end;

end;

procedure CLabel.SetText(const Value: string);
begin
  FText := Value;
  Invalidate;
  CLabel(Self.Owner).Paint;
end;

{ CodFont }

end.
