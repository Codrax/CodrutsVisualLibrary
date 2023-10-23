unit Cod.Visual.Image;

interface

uses
  SysUtils,
  Windows,
  Classes,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ExtCtrls,
  Cod.Graphics,
  Cod.VarHelpers,
  Types,
  Consts,
  Forms,
  Winapi.Messages,
  Winapi.UxTheme,
  Imaging.GIFImg,
  Cod.Components;

type

  CImageGif = class(TMPersistent)
    private
      FEnable: boolean;
      FSpeed: integer;
      function Paint : Boolean;
    published
      property Enable : boolean read FEnable write FEnable stored Paint;
      property AnimationSpeed : integer read FSpeed write FSpeed stored Paint;
  end;

  CImage = class(TGraphicControl)
  private
    FPicture: TPicture;
    FOnProgress: TProgressEvent;
    FOnFindGraphicClass: TFindGraphicClassEvent;
    FIncrementalDisplay: Boolean;
    FTransparent: Boolean;
    FDrawing: Boolean;
    FDrawMode: TDrawMode;
    FGifSettings: CImageGif;
    FOpacity: byte;
    FSmoothPicure: boolean;
    FTransparentGraphic: boolean;
    FInflationValue: integer;
    FRotationAngle: integer;
    FRotationValue: integer;
    FDrawCache: boolean;
    FCached: TBitMap;
    FCacheCreated: boolean;
    FFlipX,
    FFlipY: boolean;

    function GetCanvas: TCanvas;
    procedure PictureChanged(Sender: TObject);
    procedure SetPicture(Value: TPicture);
    procedure SetTransparent(Value: Boolean);
    procedure SetDrawMode(const Value: TDrawMode);
    procedure SetGifSettings(const Value: CImageGif);
    procedure ApplyGif;
    procedure SetOpacity(const Value: byte);
    procedure SetSmooth(const Value: boolean);
    procedure SetTransparentGraphic(const Value: Boolean);
    procedure SetInflationValue(const Value: integer);
    procedure SetRotationAngle(const Value: integer);
    procedure SetDrawCache(const Value: boolean);
    function GetCachedCanvas: TCanvas;
    procedure UpdateImageCache;
    procedure SetFlipX(const Value: boolean);
    procedure SetFlipY(const Value: boolean);

  protected
    procedure Paint; override;
    function CanObserve(const ID: Integer): Boolean; override;
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
    function DestRects: TArray<TRect>;
    function DoPaletteChange: Boolean;
    procedure Progress(Sender: TObject; Stage: TProgressStage;
      PercentDone: Byte; RedrawNow: Boolean; const R: TRect; const Msg: string); dynamic;
    procedure FindGraphicClass(Sender: TObject; const Context: TFindGraphicClassContext;
      var GraphicClass: TGraphicClass); dynamic;
    procedure CMStyleChanged(var Message: TMessage); message CM_STYLECHANGED;
    procedure Resize; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure InvalidateControl;
    procedure Inflate(up,right,down,lft: integer);

    property Canvas: TCanvas read GetCanvas;
    property CachedCanvas: TCanvas read GetCachedCanvas;

  published
    property Align;
    property Anchors;
    property AutoSize;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FlipX: boolean read FFlipX write SetFlipX default false;
    property FlipY: boolean read FFlipY write SetFlipY default false;
    property DrawCache: boolean read FDrawCache write SetDrawCache default false;
    property TransparentGraphic: Boolean read FTransparentGraphic write SetTransparentGraphic default False;
    property Smooth: boolean read FSmoothPicure write SetSmooth default true;
    property Opacity: byte read FOpacity write SetOpacity default 255;
    property RotationAngle: integer read FRotationValue write SetRotationAngle default 0;
    property InflationValue: integer read FInflationValue write SetInflationValue default 0;
    property GifSettings: CImageGif read FGifSettings write SetGifSettings;
    property DrawMode: TDrawMode read FDrawMode write SetDrawMode default TDrawMode.CenterFit;
    property IncrementalDisplay: Boolean read FIncrementalDisplay write FIncrementalDisplay default False;
    property ParentShowHint;
    property Picture: TPicture read FPicture write SetPicture;
    property PopupMenu;
    property ShowHint;
    property Touch;
    property Transparent: Boolean read FTransparent write SetTransparent default True;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnFindGraphicClass: TFindGraphicClassEvent read FOnFindGraphicClass write FOnFindGraphicClass;
    property OnGesture;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnProgress: TProgressEvent read FOnProgress write FOnProgress;
    property OnStartDock;
    property OnStartDrag;
  end;

implementation

{ CImage }

procedure CImage.ApplyGif;
begin
  if Picture.Graphic is TGIFImage then
    begin
      //PictureChanged(Self);

      (Picture.Graphic as TGIFImage).Animate := FGifSettings.Enable;
      (Picture.Graphic as TGIFImage).AnimationSpeed := FGifSettings.AnimationSpeed;

      (Picture.Graphic as TGIFImage).AnimateLoop := glContinously;
    end;
end;

function CImage.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
begin
  Result := True;
  if not (csDesigning in ComponentState) or (Picture.Width > 0) and
    (Picture.Height > 0) then
  begin
    if Align in [alNone, alLeft, alRight] then
      NewWidth := Picture.Width;
    if Align in [alNone, alTop, alBottom] then
      NewHeight := Picture.Height;
  end;
end;

function CImage.CanObserve(const ID: Integer): Boolean;
begin
  Result := False;
  if ID = TObserverMapping.EditLinkID then
    Result := True;
end;

procedure CImage.CMStyleChanged(var Message: TMessage);
var
  G: TGraphic;
begin
  inherited;
  if Transparent then
  begin
    G := Picture.Graphic;
    if (G <> nil) and not ((G is TMetaFile) or (G is TIcon)) and G.Transparent then
    begin
      G.Transparent := False;
      G.Transparent := True;
    end;
  end;
end;

constructor CImage.Create(AOwner: TComponent);
begin
  inherited;
  //interceptmouse:=True;

  FGifSettings := CImageGif.Create(Self);
  with FGifSettings do
    begin
      Enable := false;
      AnimationSpeed := GIFImageDefaultAnimationSpeed;
    end;

  FTransparent := true;
  FTransparentGraphic := false;
  FOpacity := 255;
  FCacheCreated := false;
  FDrawCache := false;

  FInflationValue := 0;
  FRotationAngle := 0;

  FSmoothPicure := true;

  ControlStyle := ControlStyle + [csReplicatable, csPannable];
  FPicture := TPicture.Create;
  FPicture.OnChange := PictureChanged;
  FPicture.OnProgress := Progress;
  FPicture.OnFindGraphicClass := FindGraphicClass;

  FDrawMode := TDrawMode.CenterFit;

  Width := 150;
  Height := 100;
end;

function CImage.DestRects: TArray<TRect>;
var
  MRect: TRect;
begin
  MRect := Rect(0, 0, Width, Height);

  if (Picture.Graphic <> nil) and not Picture.Graphic.Empty then
    try
      Result := GetDrawModeRects(MRect, Picture.Graphic, DrawMode);
    except
      Result := [MRect];
    end
  else
    Result := [MRect];
end;

destructor CImage.Destroy;
begin
  FPicture.Free;
  if FCacheCreated then
    FreeAndNil( FCached );
  inherited;
end;

function CImage.DoPaletteChange: Boolean;
var
  ParentForm: TCustomForm;
  Tmp: TGraphic;
begin
  Result := False;
  Tmp := Picture.Graphic;
  if Visible and (not (csLoading in ComponentState)) and (Tmp <> nil) and
    (Tmp.PaletteModified) then
  begin
    if (Tmp.Palette = 0) then
      Tmp.PaletteModified := False
    else
    begin
      ParentForm := GetParentForm(Self);
      if Assigned(ParentForm) and ParentForm.Active and Parentform.HandleAllocated then
      begin
        if FDrawing then
          ParentForm.Perform(wm_QueryNewPalette, 0, 0)
        else
          PostMessage(ParentForm.Handle, wm_QueryNewPalette, 0, 0);
        Result := True;
        Tmp.PaletteModified := False;
      end;
    end;
  end;
end;

procedure CImage.FindGraphicClass(Sender: TObject;
  const Context: TFindGraphicClassContext; var GraphicClass: TGraphicClass);
begin
  if Assigned(FOnFindGraphicClass) then FOnFindGraphicClass(Sender, Context, GraphicClass);
end;

function CImage.GetCachedCanvas: TCanvas;
begin
  if FCacheCreated then
    Result := FCached.Canvas
  else
    Result := Canvas;
end;

function CImage.GetCanvas: TCanvas;
var
  Bitmap: TBitmap;
begin
  if Picture.Graphic = nil then
  begin
    Bitmap := TBitmap.Create;
    try
      Bitmap.Width := Width;
      Bitmap.Height := Height;
      Picture.Graphic := Bitmap;
    finally
      Bitmap.Free;
    end;
  end;
  if Picture.Graphic is TBitmap then
    Result := TBitmap(Picture.Graphic).Canvas
  else
    raise EInvalidOperation.Create(SImageCanvasNeedsBitmap);
end;

procedure CImage.Inflate(up, right, down, lft: integer);
begin
  //UP
  Top := Top - Up;
  Height := Height + Up;

  // RIGHT
  Width := Width + right;

  // DOWN
  Height := Height + down;

  // LEFT
  Left := Left - lft;
  Width := Width + lft;
end;

procedure CImage.InvalidateControl;
begin
  Self.Invalidate;

  Paint;
end;

procedure CImage.Paint;
  procedure BeginDrawPicture(ACanvas: TCanvas; AOpacity: byte);
  var
    Rects: TArray<TRect>;
    I: integer;
    P: integer;
  begin
    with ACanvas do
      begin
        Rects := DestRects;

        // Inflate
        for I := 0 to High(Rects) do
          Rects[I].Inflate(FInflationValue, FInflationValue);

        // Flip
        if FFlipX then
          for I := 0 to High(Rects) do
            begin
              P := Rects[I].Left;
              Rects[I].Left := Rects[I].Right;
              Rects[I].Right := P;
            end;

        if FFlipY then
          for I := 0 to High(Rects) do
            begin
              P := Rects[I].Top;
              Rects[I].Top := Rects[I].Bottom;
              Rects[I].Bottom := P;
            end;

        // Draw Canvas
        for I := 0 to High(Rects) do
          if GifSettings.Enable then
            StretchDraw(Rects[I], Picture.Graphic, AOpacity)
          else
            DrawHighQuality(Rects[I], Picture.Graphic, AOpacity, not FSmoothPicure);

        // Draw Cache
        if FDrawCache and FCacheCreated then
          for I := 0 to High(Rects) do
            FCached.Canvas.DrawHighQuality(Rects[I], Picture.Graphic, AOpacity, not FSmoothPicure);
      end;
  end;

  procedure DoBufferedPaint(Canvas: TCanvas);
  var
    MemDC: HDC;
    Rect: TRect;
    PaintBuffer: HPAINTBUFFER;
  begin
    Rect := DestRects[0];
    PaintBuffer := BeginBufferedPaint(Canvas.Handle, Rect, BPBF_TOPDOWNDIB, nil, MemDC);
    try
      Canvas.Handle := MemDC;
      //Canvas.StretchDraw(DestRects[0], Picture.Graphic);
      BeginDrawPicture(Canvas, 255);
      BufferedPaintMakeOpaque(PaintBuffer, Rect);
    finally
      EndBufferedPaint(PaintBuffer, True);
    end;
  end;

var
  Save: Boolean;
  FControlCanvas: TCanvas;
begin
  FControlCanvas := inherited Canvas;

  // Design
  if csDesigning in ComponentState then
    with FControlCanvas do
    begin
      Pen.Style := psDash;
      Brush.Style := bsClear;
      Rectangle(0, 0, Width, Height);
    end;

  // Draw
  Save := FDrawing;
  FDrawing := True;
  try
    if (csGlassPaint in ControlState) and (Picture.Graphic <> nil) and
       not Picture.Graphic.SupportsPartialTransparency then
      DoBufferedPaint(FControlCanvas)
    else
      BeginDrawPicture(FControlCanvas, FOpacity);
  finally
    FDrawing := Save;
  end;
end;

procedure CImage.PictureChanged(Sender: TObject);
var
  G: TGraphic;
  D : TRect;
begin
  if Observers.IsObserving(TObserverMapping.EditLinkID) then
    if TLinkObservers.EditLinkEdit(Observers) then
      TLinkObservers.EditLinkModified(Observers);

  if AutoSize and (Picture.Width > 0) and (Picture.Height > 0) then
	SetBounds(Left, Top, Picture.Width, Picture.Height);
  G := Picture.Graphic;
  if G <> nil then
  begin
    if Assigned(Picture.Graphic) and not ((Picture.Graphic is TMetaFile) or (Picture.Graphic is TIcon)) then
      G.Transparent := FTransparentGraphic;
    D := DestRects[0];
    if (not G.Transparent) and (D.Left <= 0) and (D.Top <= 0) and
       (D.Right >= Width) and (D.Bottom >= Height) then
      ControlStyle := ControlStyle + [csOpaque]
    else  // picture might not cover entire clientrect
      ControlStyle := ControlStyle - [csOpaque];
    if DoPaletteChange and FDrawing then Update;
  end
  else ControlStyle := ControlStyle - [csOpaque];
  if not FDrawing then Invalidate;

  if Observers.IsObserving(TObserverMapping.EditLinkID) then
    if TLinkObservers.EditLinkIsEditing(Observers) then
      TLinkObservers.EditLinkUpdate(Observers);


  ApplyGif;
end;

procedure CImage.Progress(Sender: TObject; Stage: TProgressStage;
  PercentDone: Byte; RedrawNow: Boolean; const R: TRect; const Msg: string);
begin
  if FIncrementalDisplay and RedrawNow then
  begin
    if DoPaletteChange then Update
    else Paint;
  end;
  if Assigned(FOnProgress) then FOnProgress(Sender, Stage, PercentDone, RedrawNow, R, Msg);
end;

procedure CImage.Resize;
begin
  inherited;
  if FDrawCache then
    UpdateImageCache;
end;

procedure CImage.SetDrawCache(const Value: boolean);
begin
  if FDrawCache <> Value then
    begin
      FDrawCache := Value;

      UpdateImageCache;
    end;
end;

procedure CImage.SetDrawMode(const Value: TDrawMode);
begin
  FDrawMode := Value;

  Paint;
end;

procedure CImage.SetFlipX(const Value: boolean);
begin
  FFlipX := Value;

  Invalidate;
end;

procedure CImage.SetFlipY(const Value: boolean);
begin
  FFlipY := Value;

  Invalidate;
end;

procedure CImage.SetGifSettings(const Value: CImageGif);
begin
  FGifSettings := Value;

  ApplyGif;
end;

procedure CImage.SetInflationValue(const Value: integer);
begin
  FInflationValue := Value;

  Repaint;
end;

procedure CImage.SetOpacity(const Value: byte);
begin
  FOpacity := Value;

  Repaint;
end;

procedure CImage.SetPicture(Value: TPicture);
begin
  Picture.Assign(Value);
end;

procedure CImage.SetRotationAngle(const Value: integer);
begin
  FRotationValue := Value;

  Repaint;
end;

procedure CImage.SetSmooth(const Value: boolean);
begin
  FSmoothPicure := Value;

  Invalidate;
end;

procedure CImage.SetTransparent(Value: Boolean);
begin
    if Value <> FTransparent then
  begin
    FTransparent := Value;
    PictureChanged(Self);
  end;
end;

procedure CImage.SetTransparentGraphic(const Value: Boolean);
begin
  FTransparentGraphic := Value;

  PictureChanged(Self);
end;

procedure CImage.UpdateImageCache;
begin
  if FDrawCache then
    begin
      if not FCacheCreated then
        begin
          FCached := TBitMap.Create;
          FCacheCreated := true;
        end;

      FCached.Width := Width;
      FCached.Height := Height;
    end
      else
        if FCacheCreated then
          begin
            FreeAndNil(FCached);
            FCacheCreated := true;
          end;
end;

{ CImageGif }

function CImageGif.Paint: Boolean;
begin
  if Self.Owner is CImage then begin
    //CImage(Self.Owner).Paint;
    Result := True;
  end else Result := False;
end;

end.
