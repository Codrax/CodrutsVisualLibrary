unit Cod.Visual.GlassBlur;

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
  Cod.SysUtils,
  Consts,
  Vcl.Dialogs,
  Cod.Windows,
  Forms,
  Winapi.Messages,
  Messaging,
  Winapi.UxTheme,
  Imaging.GIFImg,
  Imaging.pngimage,
  System.Threading,
  System.Win.Registry,
  Cod.Components,
  IOUtils,
  Cod.Files,
  Cod.Types,
  DateUtils,
  Cod.GDI,
  Imaging.jpeg,
  Cod.ByteUtils;

type
  CGlassRefreshMode = (gdmManual, gdmTimer);

  CBlurVersion = (bvWallpaperBlurred, bvWallpaper, bvScreenshot);

  TWallpaperSetting = (wsFill, wsFit, wsStretch, wsTile, wsCenter, wsSpan);

  CGlassBlur = class(TGraphicControl)
  private
    FPicture: TPicture;
    FIncrementalDisplay: Boolean;
    FRefreshMode: CGlassRefreshMode;
    Tick: TTimer;
    FDrawing: Boolean;
    FInvalidateAbove: boolean;
    FVersion: CBlurVersion;
    FOnPaint: CComponentOnPaint;
    FDarkTheme: boolean;

    procedure TimerExecute(Sender: TObject);
    procedure SetRefreshMode(const Value: CGlassRefreshMode);
    procedure PictureChanged(Sender: TObject);
    procedure SetPicture(const Value: TPicture);
    procedure SetVersion(const Value: CBlurVersion);

    function ImageTypeExists(ImgType: CBlurVersion): boolean;
    procedure SetDarkTheme(const Value: boolean);

  protected
    function DestRect: TRect;
    procedure Paint; override;

    procedure Progress(Sender: TObject; Stage: TProgressStage;
      PercentDone: Byte; RedrawNow: Boolean; const R: TRect; const Msg: string); dynamic;
    procedure FindGraphicClass(Sender: TObject; const Context: TFindGraphicClassContext;
      var GraphicClass: TGraphicClass); dynamic;


    procedure OnVisibleChange(var Message : TMessage); message CM_VISIBLECHANGED;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure InvalidateControl;
    procedure Inflate(up,right,down,lft: integer);

    procedure FormMoveSync;

    procedure SyncroniseImage;
    procedure RebuildImage;
    procedure ReDraw;

    function GetCanvas: TCanvas;

  published
    property Align;
    property Anchors;
    property AutoSize;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property DarkTheme: boolean read FDarkTheme write SetDarkTheme;
    property Picture: TPicture read FPicture write SetPicture;
    property Version: CBlurVersion read FVersion write SetVersion;
    property RefreshMode: CGlassRefreshMode read FRefreshMode write SetRefreshMode;
    property InvalidateAbove: boolean read FInvalidateAbove write FInvalidateAbove;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Touch;
    property Visible;
    property OnClick;

    property OnPaint: CComponentOnPaint read FOnPaint write FOnPaint;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnGesture;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

  procedure GetWallpaper;
  //procedure GetWallpaperEx;
  procedure GetBlurredScreen(darkmode: boolean);
  function GetWallpaperName(ScreenIndex: integer; TranscodedDefault: boolean = false): string;
  function GetWallpaperSize: integer;
  function GetWallpaperSetting: TWallpaperSetting;
  function GetCurrentExtension: string;
  procedure CreateBySignature(var Wallpaper: TGraphic; Sign: TFileType);
  procedure CreateByExtension(var Wallpaper: TGraphic; Extension: string);

var
  WorkingAP: boolean;
  Wallpaper: TBitMap;
  WallpaperBMP: TBitMap;
  WallpaperBlurred: TBitMap;
  ScreenshotBlurred: TBitMap;


  LastDetectedFileSize: integer;
  LastSyncTime: TDateTime;

implementation

function GetWallpaperSize: integer;
begin
  Result := GetFileSize( GetWallpaperName(999) );
end;

function GetWallpaperSetting: TWallpaperSetting;
var
  R: TRegistry;
  Value: integer;
  TileWallpaper: boolean;
begin
  // Create registry
  R := TRegistry.Create(KEY_READ);
  Result := TWallpaperSetting.wsStretch;
  R.RootKey := HKEY_CURRENT_USER;
  try
    if R.OpenKeyReadOnly('Control Panel\Desktop') then
      begin
        Value := R.ReadString('WallpaperStyle').ToInteger;
        TileWallpaper := R.ReadString('TileWallpaper').ToBoolean;

        // Clear String
        case Value of
          0: if TileWallpaper then
              Result := TWallpaperSetting.wsTile
                else
                  Result := TWallpaperSetting.wsCenter;
          2: Result := TWallpaperSetting.wsStretch;
          6: Result := TWallpaperSetting.wsFit;
          10: Result := TWallpaperSetting.wsFill;
          22: Result := TWallpaperSetting.wsSpan;
          else Result := wsStretch;
        end;
      end;
  finally
    // Free Memory
    R.Free;
  end;
end;

function GetWallpaperName(ScreenIndex: integer; TranscodedDefault: boolean): string;
begin
  if NTKernelVersion <= 6.1 then
    Result := GetUserShellLocation(TUserShellLocation.AppData) + '\Microsoft\Windows\Themes\TranscodedWallpaper.jpg'
  else
    begin
      Result := GetUserShellLocation(TUserShellLocation.AppData) + '\Microsoft\Windows\Themes\Transcoded_' +
        IntToStrIncludePrefixZeros(ScreenIndex, 3);

      if TranscodedDefault or not TFile.Exists(Result) then
        Result := GetUserShellLocation(TUserShellLocation.AppData) + '\Microsoft\Windows\Themes\TranscodedWallpaper';
    end;
end;

procedure GetWallpaper;
var
  DeskRect: TRect;
begin
  (* This method is objectively better than loading all files manually and colaging them! Screenshot the program Manager! *)
  // Working
  WorkingAP := true;

  // Get Rects
  DeskRect := Screen.DesktopRect;

  // Create Images
  WallpaperBlurred := TBitMap.Create(DeskRect.Width, DeskRect.Height);

  // Screenshot
  ScreenShotApplication(WallpaperBlurred, 'Program Manager');

  // Normal
  WallpaperBMP := TBitMap.Create(DeskRect.Width, DeskRect.Height);
  WallpaperBMP.Assign( WallpaperBlurred );

  // Blur
  FastBlur(WallpaperBlurred, 8, 10, false); // 8 16

  // Get Size
  LastDetectedFileSize := GetWallpaperSize;
  LastSyncTime := Now;

  // Finish Work
  WorkingAP := false;
end;

{procedure GetWallpaperEx;
var
  Filename: string;

  DestRect: TRect;

  DRects: TArray<TRect>;

  DeskRect,
  MonitorRect: TRect;

  I, J, OffsetX, OffsetY: integer;

  Extension: string;

  TranscodedDefault: boolean;

  WallpaperSetting: TWallpaperSetting;
  DrawMode: TDrawMode;

  BitMap: TBitMap;
begin
  if WorkingAP then
    Exit;

  // Windows Xp and below compatability
  if NTKernelVersion <= 5.2 then
    Exit;

  // Working
  WorkingAP := true;

  // Get Rects
  DeskRect := Screen.DesktopRect;

  OffsetX := abs(Screen.DesktopRect.Left);
  OffsetY := abs(Screen.DesktopRect.Top);

  // Create Images
  WallpaperBlurred := TBitMap.Create(DeskRect.Width, DeskRect.Height);

  WallpaperBlurred.Canvas.Brush.Color := clBlack;
  WallpaperBlurred.Canvas.FillRect(WallpaperBlurred.Canvas.ClipRect);

  // Prepare
  WallpaperSetting := GetWallpaperSetting;

  TranscodedDefault := Screen.MonitorCount = 1;

  // Rects Draw Mode
  case WallpaperSetting of
    wsFill: DrawMode := TDrawMode.Center3Fill;
    wsFit: DrawMode := TDrawMode.CenterFit;
    wsStretch: DrawMode := TDrawMode.Stretch;
    wsTile: DrawMode := TDrawMode.Tile;
    wsCenter: DrawMode := TDrawMode.Center;
    wsSpan: DrawMode := TDrawMode.CenterFill;
    else DrawMode := TDrawMode.Stretch;
  end;

  if WallpaperSetting = wsSpan then
    // Fill Image with Wallpaper
    begin
      // Single-File Extension
      Extension := GetCurrentExtension;

      // Get Transcoded
      CreateByExtension( TGraphic(Wallpaper), Extension );
      FileName := GetWallpaperName(0);

      if not fileexists(FileName) then
        Exit;

      Wallpaper.LoadFromFile(FileName);
      DrawImageInRect(WallpaperBlurred.Canvas, WallpaperBlurred.Canvas.ClipRect, Wallpaper, TDrawMode.CenterFill);
    end
  else
    // Complete Desktop Puzzle
    for I := 0 to Screen.MonitorCount - 1 do
      begin
        // Get Transcoded
		FileName := GetWallpaperName(Screen.Monitors[I].MonitorNum, TranscodedDefault); 

        if not fileexists(FileName) then
          Break;

		// Create Extension
        CreateBySignature( TGraphic(Wallpaper), ReadFileSignature(FileName) );

        // Load
        try
          Wallpaper.LoadFromFile(FileName);
        except
          Break;
        end;

        // Draw Monitor
        MonitorRect := Screen.Monitors[I].BoundsRect;

        DestRect := MonitorRect;
        DestRect.Offset(OffsetX, OffsetY);

        DRects := GetDrawModeRects(DestRect, Wallpaper, DrawMode);

        // Draw
        if WallpaperSetting in [wsFit, wsStretch] then
          for J := 0 to High(DRects) do
            WallpaperBlurred.Canvas.StretchDraw(DRects[J], Wallpaper, 255)
          else
            begin
              Bitmap := TBitMap.Create(DestRect.Width, DestRect.Height);
              for J := 0 to High(DRects) do
                begin
                  DRects[J].Offset(-DestRect.Left, -DestRect.Top);

                  Bitmap.Canvas.StretchDraw(DRects[J], Wallpaper, 255)
                end;

              WallpaperBlurred.Canvas.StretchDraw(DestRect, Bitmap, 255)
            end;
      end;

  WallpaperBMP := TBitMap.Create(DeskRect.Width, DeskRect.Height);
  WallpaperBMP.Assign( WallpaperBlurred );

  // Blur
  FastBlur(WallpaperBlurred, 8, 10, false); // 8 16

  // Get Size
  LastDetectedFileSize := GetWallpaperSize;
  LastSyncTime := Now;

  // Finish Work
  WorkingAP := false;
end; }

procedure GetBlurredScreen(darkmode: boolean);
begin
  // Working
  WorkingAP := true;

  // Get Screenshot
  ScreenshotBlurred := TBitMap.Create;
  QuickScreenShot( ScreenshotBlurred );

  // Effects
  FastBlur(ScreenshotBlurred, 6, 8, false);

  //ScreenshotBlurred.SaveToFile( 'C:\Test\File.bmp' );

  if darkmode then
    TintPicture(ScreenshotBlurred.Canvas, ScreenshotBlurred.Canvas.ClipRect, 0, 75)
  else
    TintPicture(ScreenshotBlurred.Canvas, ScreenshotBlurred.Canvas.ClipRect, clWhite, 200);

  // Time
  LastSyncTime := Now;

  // Finish
  WorkingAP := false;
end;

function GetCurrentExtension: string;
var
  R: TRegistry;
  Bytes: TBytes;
begin
  // Windows7
  if NTKernelVersion <= 6.1 then
    Exit('.jpeg');

  // Create registry
  R := TRegistry.Create(KEY_READ);

  R.RootKey := HKEY_CURRENT_USER;
  try
    if R.OpenKeyReadOnly('Control Panel\Desktop') then
      begin
        SetLength(Bytes, R.GetDataSize('TranscodedImageCache'));
        R.ReadBinaryData('TranscodedImageCache', Pointer(Bytes)^, Length(Bytes));

        // Clear String
        Result := ExtractFileName( TEncoding.ASCII.GetString(Bytes) );
        Result := AnsiLowerCase( Trim( ExtractFileExt( Result ) ).Replace(#0, '') );
      end;
  finally
    // Free Memory
    R.Free;
  end;
end;

procedure CreateBySignature(var Wallpaper: TGraphic; Sign: TFileType);
begin
  case Sign of
    { Png }
    TFileType.PNG: Wallpaper := TPngImage.Create;

    { Jpeg }
    TFileType.JPEG: Wallpaper := TJpegImage.Create;

    { Gif }
    TFileType.GIF: Wallpaper := TGifImage.Create;

    { Heif? }
    //dftHEIF: ;

    { Default }
    else Wallpaper := TBitMap.Create;
  end;
end;

procedure CreateByExtension(var Wallpaper: TGraphic; Extension: string);
begin
  { Jpeg }
  if (Extension = '.jpg') or (Extension = '.jpeg') then
    Wallpaper := TJpegImage.Create
      else
        { Png }
        if Extension = '.png' then
          Wallpaper := TPngImage.Create
          else
            { Gif }
            if Extension = '.gif' then
              Wallpaper := TGifImage.Create
                else
                  { Bitmap }
                  if Extension = '.bmp' then
                    Wallpaper := TBitMap.Create
                      else
                        { Default }
                        Wallpaper := TJpegImage.Create;
end;


{ CGlassBlur }

constructor CGlassBlur.Create(AOwner: TComponent);
begin
  inherited;
  //interceptmouse:=True;

  // Picture
  FPicture := TPicture.Create;
  FPicture.OnChange := PictureChanged;
  FPicture.OnProgress := Progress;
  FPicture.OnFindGraphicClass := FindGraphicClass;

  ControlStyle := ControlStyle + [csReplicatable, csPannable];

  // Timer
  Tick := TTimer.Create(Self);
  with Tick do
    begin
      Interval := 1;
      Enabled := false;
      OnTimer := TimerExecute;
    end;

  // Dark Theme
  FDarkTheme := true;

  // Settings
  FInvalidateAbove := false;

  FVersion := bvWallpaperBlurred;

  // Size
  Width := 150;
  Height := 200;
end;

function CGlassBlur.DestRect: TRect;
begin
  Result := Rect(0, 0, Width, Height);
end;

destructor CGlassBlur.Destroy;
begin
  FPicture.Free;

  Tick.Enabled := false;
  FreeAndNil(Tick);
  inherited;
end;


procedure CGlassBlur.FindGraphicClass(Sender: TObject;
  const Context: TFindGraphicClassContext; var GraphicClass: TGraphicClass);
begin

end;

procedure CGlassBlur.FormMoveSync;
begin
  SyncroniseImage;
end;

function CGlassBlur.GetCanvas: TCanvas;
begin
  Result := Self.Canvas;
end;

function CGlassBlur.ImageTypeExists(ImgType: CBlurVersion): boolean;
begin
  Result := false;
  case ImgType of
    bvWallpaperBlurred: Result := (WallpaperBlurred  <> nil) and (not WallpaperBlurred.Empty);
    bvWallpaper: Result := (WallpaperBMP  <> nil) and (not WallpaperBMP.Empty);
    bvScreenshot: Result := (ScreenshotBlurred  <> nil) and (not ScreenshotBlurred.Empty);
  end;
end;

procedure CGlassBlur.Inflate(up, right, down, lft: integer);
begin
  //UP
  Top := Top - Up;
  Height := Height + Up;
//RIGHT
  Width := Width + right;
//DOWN
  Height := Height + down;
//LEFT
  Left := Left - lft;
  Width := Width + lft;
end;

procedure CGlassBlur.InvalidateControl;
begin
  Self.Invalidate;

  Paint;
end;

procedure CGlassBlur.OnVisibleChange(var Message: TMessage);
begin
  if Self.Visible then
    SyncroniseImage;
end;

procedure CGlassBlur.Paint;
var
  Save: Boolean;
  Pict: TBitMap;
  DrawRect, ImageRect: Trect;
begin
  // Disable Timer After Successfull Draw
  if (not ImageTypeExists(Version)) and (not (csDesigning in ComponentState)) then
    Tick.Enabled := RefreshMode = gdmTimer;

  // Draw
  if csDesigning in ComponentState then
    with inherited Canvas do
    begin
      Pen.Style := psDash;
      Brush.Style := bsClear;
      Rectangle(0, 0, Width, Height);
    end;

  Save := FDrawing;
  FDrawing := True;
  try
      with inherited Canvas do
        begin
          // Draw Canvas
          { Image Draw }

          if (WorkingAP) or not ImageTypeExists(Version) then
            begin
              Brush.Color := 0;
              FillRect(ClipRect);

              Exit;
            end;

          DrawRect := Rect(0, 0, Width, Height);

          ImageRect := ClientToScreen( ClientRect );
          ImageRect.Offset(Screen.DesktopRect.Left * -1, Screen.DesktopRect.Top * -1);

          // Calc Rect
          {PictureRect.Top := trunc((ImageRect.Top * WallpaperBlurred.Height) / Screen.Height);
          PictureRect.Left := trunc((ImageRect.Left * WallpaperBlurred.Width) / Screen.Width);
          PictureRect.Bottom := trunc((ImageRect.Bottom * WallpaperBlurred.Height) / Screen.Height);
          PictureRect.Right := trunc((ImageRect.Right * WallpaperBlurred.Width) / Screen.Width);    }

          // Create Picture
          Pict := TBitMap.Create(Width, Height);

          // Copy Rect
          case Version of
            bvWallpaperBlurred: Pict.Canvas.CopyRect(DrawRect, WallpaperBlurred.Canvas, ImageRect);
            bvWallpaper: Pict.Canvas.CopyRect(DrawRect, WallpaperBMP.Canvas, ImageRect);
            bvScreenshot: Pict.Canvas.CopyRect(DrawRect, ScreenshotBlurred.Canvas, ImageRect);
          end;

          // Debug
          {with Pict.Canvas do
            begin
              TextOut(10, 40, 'DRAW-RECT P2 ' + 'TopLeft=' +
                      DrawRect.Left.ToString + ',' + DrawRect.Top.ToString +
                      ' BottomLeft=' + DrawRect.Bottom.ToString + ',' + DrawRect.Right.ToString);
              TextOut(10, 70, 'PICUTURE-RECT P2 ' + 'TopLeft=' +
                      PictureRect.Left.ToString + ',' + PictureRect.Top.ToString +
                      ' BottomLeft=' + PictureRect.Bottom.ToString + ',' + PictureRect.Right.ToString);

            end;     }

          // Draw
          //DrawHighQuality(DestRect, Pict, 255, false);
          FPicture.Bitmap.Assign(Pict);

          DrawHighQuality(DestRect, FPicture.Graphic, 255, false);

          Pict.Free;
        end;
  finally
    FDrawing := Save;

    // Notify
    if Assigned(FOnPaint) then
      FOnPaint( Self );
  end;
end;

procedure CGlassBlur.PictureChanged(Sender: TObject);
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
      G.Transparent := false;
    D := DestRect;
    if (not G.Transparent) and (D.Left <= 0) and (D.Top <= 0) and
       (D.Right >= Width) and (D.Bottom >= Height) then
      ControlStyle := ControlStyle + [csOpaque]
    else  // picture might not cover entire clientrect
      ControlStyle := ControlStyle - [csOpaque];

  end
  else ControlStyle := ControlStyle - [csOpaque];
  if not FDrawing then Invalidate;

  if Observers.IsObserving(TObserverMapping.EditLinkID) then
    if TLinkObservers.EditLinkIsEditing(Observers) then
      TLinkObservers.EditLinkUpdate(Observers);
end;

procedure CGlassBlur.Progress(Sender: TObject; Stage: TProgressStage;
  PercentDone: Byte; RedrawNow: Boolean; const R: TRect; const Msg: string);
begin
if FIncrementalDisplay and RedrawNow then
  begin
    Paint;
  end;
end;

procedure CGlassBlur.RebuildImage;
begin
  case Version of
    bvWallpaperBlurred, bvWallpaper: GetWallpaper;
    bvScreenshot: GetBlurredScreen(FDarkTheme);
  end;
end;

procedure CGlassBlur.ReDraw;
begin
  PictureChanged(Self);
end;

procedure CGlassBlur.SetDarkTheme(const Value: boolean);
begin
  FDarkTheme := Value;

  if Version = bvScreenshot then
    RebuildImage;
end;

procedure CGlassBlur.SetPicture(const Value: TPicture);
begin
  FPicture.Assign(Value);
end;

procedure CGlassBlur.SetRefreshMode(const Value: CGlassRefreshMode);
begin
  FRefreshMode := Value;

  if not (csDesigning in ComponentState) then
    Tick.Enabled := Value = gdmTimer;
end;

procedure CGlassBlur.SetVersion(const Value: CBlurVersion);
begin
  FVersion := Value;

  Paint;
end;

procedure CGlassBlur.SyncroniseImage;
begin
  // Paint
  ReDraw;

  // Check for different wallpaper
  case Version of
    bvWallpaperBlurred, bvWallpaper: if (GetWallpaperSize <> LastDetectedFileSize) then
      RebuildImage;
    bvScreenshot: if (ScreenshotBlurred = nil) or (SecondsBetween(LastSyncTime, Now) > 1) then
      RebuildImage;
  end;

  // Full Redraw
  if FInvalidateAbove then
    Invalidate;
end;

procedure CGlassBlur.TimerExecute(Sender: TObject);
begin
  if not IsInIDE then
    SyncroniseImage;
end;

end.
