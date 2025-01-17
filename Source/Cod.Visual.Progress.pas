unit Cod.Visual.Progress;

interface

uses
  SysUtils,
  Classes,
  Vcl.Controls,
  Types,
  Vcl.ExtCtrls,
  Cod.Visual.CPSharedLib,
  Math,
  Vcl.Forms,
  WinApi.Windows,
  Vcl.Graphics,
  Vcl.Themes,
  Vcl.Styles,
  Cod.Components,
  Cod.Graphics,
  Cod.Types;

type
  CProgress = class;
  CProgressPreset = (cprNone, cprStandard, cprError, cprBlue, cprMarble, cprModern, cprBeacon, cprWindows);
  CProgressAnimTypes = (atyNone, atyFade, atySolid);
  CProgressChange = procedure(Sender : CProgress; Position, Max: integer) of object;

  CProgressColors = class(TMPersistent)
    private
    FForeground, FBackground: TColor;
    FSyncBgColor: boolean;
    published
      property Foreground : TColor read FForeground write FForeground;
      property Background : TColor read FBackground write FBackground;
      property FormSyncedColor : boolean read FSyncBgColor write FSyncBgColor;
  end;

  CProgressText = class(TMPersistent)
    private
      SText: string;
      FSEnable,
      FIncludePerc, FFitToTx: boolean;
      FTextCol: TColor;
      FTextSz,
      FWidLimit : integer;
      FTextNm : TFontName;

      procedure SetSText(const Value: string);
      procedure SetEnableSText(const Value: boolean);
      procedure SetInclPerc(const Value: boolean);
      procedure SetFontNm(const Value: TFontName);
      procedure SetFnSize(const Value: integer);
      procedure SetFnColor(const Value: TColor);
      procedure SetWLimit(const Value: integer);
      procedure SetFtText(const Value: boolean);
    published
      property CaptionText : string read SText write SetSText;
      property FontColor : TColor read FTextCol write SetFnColor;
      property FontSize : integer read FTextSz write SetFnSize;
      property TextWidthLimit : integer read FWidLimit write SetWLimit;
      property FontName : TFontName read FTextNm write SetFontNm;
      property Enabled : boolean read FSEnable write SetEnableSText;
      property FitToText : boolean read FFitToTx write SetFtText;
      property IncludePercent : boolean read FIncludePerc write SetInclPerc;
  end;

  CProgressOptions = class(TMPersistent)
    private
      FRoundInt: integer;
      FBordColor: TColor;
      //exceptpreset: boolean;
    published
      property BorderRadius : integer read FRoundInt write FRoundInt;
      property BorderColor : TColor read FBordColor write FBordColor;
      //property PresetException: boolean read exceptpreset write exceptpreset;
  end;

  CProgressAnimation = class(TMPersistent)
    private
    FInterval, FStep, FAnimateTo: integer;
    FAnimations: boolean;
    published
      property Animations: boolean read FAnimations write FAnimations;
      property Interval: integer read FInterval write FInterval;
      property Step: integer read FStep write FStep;
  end;

  CProgressAnimate = class(TMPersistent)
    private
      currentp, fadesize, timerspeed, FCustomX, FCustomY, aincspeed: integer;
      FSelectAnimation : CProgressAnimTypes;
      FAllowProgressAnimate, FCustomRez: boolean;
      procedure ChengeALlowANi(const Value: boolean);
      procedure ChangeAnimProgSpeed(const Value: integer);
    published
      property Enable: boolean read FAllowProgressAnimate write ChengeAllowAni;
      property FadeSizing: integer read fadesize write fadesize;
      property TimerAnimateSpeed: integer read timerspeed write ChangeAnimProgSpeed;
      property CustomRezolution: boolean read FCustomRez write FCustomRez;
      property CustomRezX: integer read FCustomX write FCustomX;
      property CustomRezY: integer read FCustomY write FCustomY;
      property AnimateIncSpeed: integer read aincspeed write aincspeed;
      property AnimationSelector: CProgressAnimTypes read FSelectAnimation write FSelectAnimation;
  end;

  CProgress = class(TCustomTransparentControl)
      constructor Create(AOwner : TComponent); override;
      destructor Destroy; override;
    private
      FAuthor, FSite, FVersion: string;

      FProgressText: CProgressText;
      FColors: CProgressColors;
      FOnChange: CProgressChange;
      FAnimation: CProgressAnimation;
      FProgAnim: CProgressAnimate;
      FProgOptions: CProgressOptions;
      FPreset: CProgressPreset;
      AnimateInIDE: boolean;
      FMax, FMin: integer;
      FPosition: integer;
      FAnimationTimer: TTimer;
      FDrawAnim: TTimer;
      FAccent: CAccentColor;
      FTrueTransparency: boolean;

      function ChangeColorSat(clr: TColor; perc: integer): TColor;
      function TruncToLimit(tx: string): string;
      procedure FAnimationTimerEvent(Sender: TObject);
      procedure FDrawAnimEvent(Sender: TObject);
      procedure SetMax(const Value: integer);
      procedure SetMin(const Value: integer);
      procedure SetPosition(const Value: integer);
      procedure SetPresets(const Value: CProgressPreset);
      procedure ApplyAccentColor;
      procedure SetAccentColor(const Value: CAccentColor);
      procedure SetTrueTransparency(const Value: boolean);

    protected
      procedure Paint; override;

    published
      property OnMouseEnter;
      property OnMouseLeave;
      property OnMouseDown;
      property OnMouseUp;
      property OnMouseMove;
      property OnClick;
      property OnChange : CProgressChange read FOnChange write FOnChange;

      property ShowHint;
      property Align;
      property Anchors;
      property Cursor;
      property Visible;
      property Enabled;
      property Constraints;
      property DoubleBuffered;

      property TrueTransparency: boolean read FTrueTransparency write SetTrueTransparency;
      property AccentColor : CAccentColor read FAccent write SetAccentColor;
      property Presets : CProgressPreset read FPreset write SetPresets;
      property TextOverlay : CProgressText read FProgressText write FProgressText;
      property EnableAnimateInIDE : boolean read AnimateInIDE write AnimateInIDE;
      property ProgressbarOptions : CProgressOptions read FProgOptions write FProgOptions;
      property Colors : CProgressColors read FColors write FColors;
      property AnimateProgress : CProgressAnimate read FProgAnim write FProgAnim;
      property Animations: CProgressAnimation read FAnimation write FAnimation;

      property Position : integer read FPosition write SetPosition;
      property Max : integer read FMax write SetMax;
      property Min : integer read FMin write SetMin;
      procedure SetValue(pos: integer; jump: boolean = false);

      property &&&Author: string Read FAuthor;
      property &&&Site: string Read FSite;
      property &&&Version: string Read FVersion;
    public
      procedure Invalidate; override;
  end;

implementation

{ CProgressColors }


{ CProgress }

procedure CProgress.ApplyAccentColor;
var
  AccColor: TColor;
begin
  if FAccent = CAccentColor.None then
    Exit;

  AccColor := GetAccentColor(FAccent);

  FColors.FForeground := AccColor;
end;

function CProgress.ChangeColorSat(clr: TColor; perc: integer): TColor;
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

constructor CProgress.Create(AOwner: TComponent);
begin
  inherited;
  FAuthor                       := 'Petculescu Codrut';
  FSite                         := 'https://www.codrutsoftware.cf';
  FVersion                      := '1.4';

  interceptmouse:=True;

  FTrueTransparency := true;

  FAnimation := CProgressAnimation.Create(self);
  with FAnimation do begin
    Animations := True;
    Interval := 1;
    Step := 1;
  end;

  FColors := CProgressColors.Create(self);
  with FColors do begin
    FForeground := 54528;
    FBackground := clWhite;
    FSyncBgColor := true;
  end;

  FProgressText := CProgressText.Create(self);
  with FProgressText do begin
    FTextCol := clBlack;
    FTextSz := 8;
    FWidLimit := -2;
    FFitToTx := false;
    FTextNm := 'Tahoma';
    SText := 'Loading';
    FSEnable := false;
    FIncludePerc := true;
  end;

FAnimationTimer := TTimer.Create(nil);
  with FAnimationTimer do begin
    Interval := FAnimation.Interval;
    OnTimer := FAnimationTimerEvent;
    Enabled := false;
  end;

  FDrawAnim := TTimer.Create(nil);
  with FDrawAnim do begin
    Interval := 1;
    OnTimer := FDrawAnimEvent;
    Enabled := true;
  end;

  FProgAnim := CProgressAnimate.Create(self);
  with FProgAnim do begin
    FSelectAnimation := atyFade;
    FAllowProgressAnimate := true;
    timerspeed := 1;
    fadesize := 100;
    currentp := 0;
    aincspeed := 2;
  end;

  FProgOptions := CProgressOptions.Create(self);
  with FProgOptions do begin
    FRoundInt := 16;
    FBordColor := clWhite;
  end;

  FPreset := CProgressPreset.cprNone;

  FAccent := CAccentColor.AccentAdjust;
  ApplyAccentColor;

  Width := 200;
  Height := 20;

  FPosition := 0;
  FMax := 100;
end;

destructor CProgress.Destroy;
begin
  FreeAndNil(FAnimation);
  FreeAndNil(FColors);
  FreeAndNil(FProgAnim);
  FreeAndNil(FProgressText);
  FreeAndNil(FProgOptions);
  FAnimationTimer.Enabled := false;
  FreeAndNil(FAnimationTimer);
  FDrawAnim.Enabled := false;
  FreeAndNil(FDrawAnim);
  inherited;
end;

procedure CProgress.FAnimationTimerEvent(Sender: TObject);
begin
  if FAnimationTimer.Tag = 0 then begin // --
    if FPosition <= FAnimation.FANimateTo then begin
      FPosition := FAnimation.FAnimateTo;
      FAnimationTimer.Enabled := False;
    end  else dec(FPosition,FAnimation.Step)
  end else if FAnimationTimer.Tag = 1 then begin // ++
    if FPosition >= FAnimation.FAnimateTo then begin
      FPosition := FAnimation.FAnimateTo;
      FAnimationTimer.Enabled := False;
    end else inc(FPosition,FAnimation.Step)
  end;
  if Assigned(FOnChange) then FOnChange(self, FPosition, FMax);
  Paint;
end;

procedure CProgress.FDrawAnimEvent(Sender: TObject);
begin
  if ( (Parent.Visible) or (AnimateInIDE) ) and (Visible) and (Application.Active) then
  Paint;
end;

procedure CProgress.Invalidate;
begin
  inherited;

  ApplyAccentColor;
end;

procedure CProgress.Paint;
var
  I: integer;
  workon, revision: TBitMap;
  outtx: string;
  FSubstractDif: integer;
begin
  inherited;
  ApplyAccentColor;

  if FColors.FSyncBgColor then
  begin
    if StrInArray(TStyleManager.ActiveStyle.Name, nothemes) then begin
      FProgOptions.FBordColor := GetParentForm(Self).Color;
    end else
      FProgOptions.FBordColor := TStyleManager.ActiveStyle.GetSystemColor(clBtnFace);
  end;

  SetPresets(FPreset);
  workon := TBitMap.Create;
  try
    //Custom Rezoultion
    if FProgAnim.CustomRezolution then begin
      workon.Width := FProgAnim.CustomRezX;
      workon.Height := FProgAnim.CustomRezY;
    end else begin
      workon.Width := Width;
      workon.Height := Height;
    end;
    //Start Draw
    FSubstractDif := FMax-FMin;
    if FSubstractDif = 0 then
      FSubstractDif := 1;
  with workon.Canvas do begin
    Brush.Color := FColors.Background;
    FillRect( ClipRect );
    Brush.Color := FColors.Foreground;
    try FillRect( Rect(0, 0, ((FPosition-FMin) * workon.Width) div FSubstractDif, workon.Height) ); except end;


  //Animation
  if FProgAnim.FAllowProgressAnimate then begin
    case FProgAnim.FSelectAnimation of
  atyFade:  begin
  //Wave 1
        for I := FProgAnim.currentp to FProgAnim.currentp + FProgAnim.fadesize do begin
          pen.Color := ChangeColorSat(FColors.Foreground,trunc( FProgAnim.fadesize - ((i - FProgAnim.currentp) / FProgAnim.fadesize) * FProgAnim.fadesize ) );
          MoveTo(i,0);
          if NOT (i + 1 > trunc((workon.Width / FSubstractDif) * (FPosition-FMin))) then
            LineTo(i,workon.Height);
        end;
        //Wave 2
        for I := FProgAnim.currentp downto FProgAnim.currentp - FProgAnim.fadesize do begin
          pen.Color := ChangeColorSat(FColors.Foreground,trunc( FProgAnim.fadesize - ((i - FProgAnim.currentp) / FProgAnim.fadesize) * -FProgAnim.fadesize ) );
          MoveTo(i,0);
          if NOT (i + 1  > trunc((workon.Width / FSubstractDif) * (FPosition-FMin))) then
            LineTo(i,workon.Height);
        end;

        FProgAnim.currentp := FProgAnim.currentp + FProgAnim.aincspeed;
        if (max <> 0) and (FProgAnim.currentp - FProgAnim.fadesize > trunc((workon.Width / max) * (FPosition-FMin))) then
          FProgAnim.currentp := FProgAnim.fadesize * -1;
      end;
  atySolid:  begin
        brush.Color := FColors.Background;
        FillRect(BoundsRect);
        brush.Color := FColors.Foreground;
        FillRect(Rect(FProgAnim.currentp - FProgAnim.fadesize,0,FProgAnim.currentp + FProgAnim.fadesize,workon.Height) );

        FProgAnim.currentp := FProgAnim.currentp + FProgAnim.aincspeed;
        if FProgAnim.currentp - FProgAnim.fadesize > workon.Width then FProgAnim.currentp := FProgAnim.fadesize * -1;
      end;
    end;
  end;

  //Text OverLay
  with FProgressText do begin
    if FSEnable then begin
      if ((FWidLimit > 0) or (FWidLimit = -2)) then
        outtx := TruncToLimit(SText)
      else
        outtx := SText;
      if FIncludePerc then outtx := outtx + ' ' + inttostr((FPosition-FMin)) + '%';

      if FFitToTx then Width := Canvas.TextWidth( outtx ) + 25;
      

      Pen.Style := psClear;
      Brush.Style := bsClear;

      Font.Name := FTextNm;
      Font.Color := FTextCol;
      Font.Size := FTextSz;

      TextOut( (Width div 2) - ( TextWidth(outtx) div 2 ) , (Height div 2) - ( TextHeight(outtx) div 2 ) , outtx);
    end;
  end;


  end;
  finally
    // Final Preparations
    revision := TBitMap.Create(Width, Height);

    revision.Canvas.CopyRect(revision.Canvas.ClipRect,workon.Canvas,workon.canvas.ClipRect);


    with revision.canvas do begin
    //Border
      Brush.Style := bsClear;
      Pen.Color := FProgOptions.FBordColor;
      for I := 1 to FProgOptions.FRoundInt do
        RoundRect(0, 0, Width + 1, Height + 1, I, I);
   end;

   if FTrueTransparency then
    CopyRoundRect(revision.Canvas, MakeRoundRect(revision.Canvas.ClipRect,
                  FProgOptions.FRoundInt, FProgOptions.FRoundInt),
                  Canvas, Canvas.ClipRect, 1)
   else
    Canvas.CopyRect(Rect(0,0,width,height),revision.Canvas,revision.canvas.ClipRect);

    revision.Free;
    workon.Free;
  end;
end;

procedure CProgress.SetAccentColor(const Value: CAccentColor);
begin
  FAccent := Value;

  if Value <> CAccentColor.None then
    ApplyAccentColor;

  Paint;
end;

procedure CProgress.SetMax(const Value: integer);
begin
  FMax := Value;
  if FPosition > FMax then FPosition := FMax;
  Paint;
end;

procedure CProgress.SetMin(const Value: integer);
begin
  FMin := Value;
  if FPosition < FMin then
    FPosition := FMin;
  Paint;
end;

procedure CProgress.SetPosition(const Value: integer);
begin
  // Equal
  if FPosition = Value then
    Exit;

  // Check Direction
  if (Value <= FMax) and (Value >= FMin) then begin
    if FAnimation.Animations then begin
        if Value < FPosition then
          FAnimationTimer.Tag :=0 // --
        else if Value > Position then
          FAnimationTimer.Tag := 1; // ++

        FAnimation.FAnimateTo := Value;
        FAnimationTimer.Interval := FAnimation.Interval;
        FAnimationTimer.Enabled := true;
        Paint;
    end else begin
      FPosition := Value;
      if Assigned(FOnChange) then FOnChange(self, FPosition, FMax);
      Paint;
    end;
  end;

  // Reading
  if csReading in ComponentState then
    FPosition := Value;
end;

procedure CProgress.SetPresets(const Value: CProgressPreset);
begin
  //if FProgOptions.exceptpreset then Exit;
  FPreset := Value;


  case FPreset of
    CProgressPreset.cprMarble: begin
      FProgAnim.aincspeed := 5;
      FAnimation.FAnimations := true;
      FColors.FForeground := $0000D500;
      FColors.Background := clWhite;
      FProgAnim.fadesize := 100;
      FProgAnim.FSelectAnimation := atySolid;
      FProgAnim.FCustomRez := false;
      FProgAnim.FCustomY := 0;
      FProgAnim.FCustomX := 0;
      FProgAnim.timerspeed := 1;
      FProgAnim.FAllowProgressAnimate := true;
      FProgOptions.FRoundInt := 16;
    end;
    CProgressPreset.cprStandard: begin
      FProgAnim.aincspeed := 2;
      FAnimation.FAnimations := true;
      FColors.FForeground := $0000D500;
      FColors.Background := clWhite;
      FProgAnim.fadesize := 100;
      FProgAnim.FSelectAnimation := atyFade;
      FProgAnim.FCustomRez := false;
      FProgAnim.FCustomY := 0;
      FProgAnim.FCustomX := 0;
      FProgAnim.timerspeed := 1;
      FProgAnim.FAllowProgressAnimate := true;
      FProgOptions.FRoundInt := 16;
    end;
    CProgressPreset.cprWindows: begin
      FProgAnim.aincspeed := 2;
      FAnimation.FAnimations := true;
      FColors.FForeground := $0000D500;
      FColors.Background := clWhite;
      FProgAnim.fadesize := 100;
      FProgAnim.FSelectAnimation := atyFade;
      FProgAnim.FCustomRez := false;
      FProgAnim.FCustomY := 0;
      FProgAnim.FCustomX := 0;
      FProgAnim.timerspeed := 1;
      FProgAnim.FAllowProgressAnimate := true;
      FProgOptions.FRoundInt := 1;
    end;
    CProgressPreset.cprError: begin
      FProgAnim.aincspeed := 2;
      FAnimation.FAnimations := true;
      FColors.FForeground := clRed;
      FColors.Background := clWhite;
      FProgAnim.fadesize := 100;
      FProgAnim.FSelectAnimation := atyFade;
      FProgAnim.FCustomRez := false;
      FProgAnim.FCustomY := 0;
      FProgAnim.FCustomX := 0;
      FProgAnim.timerspeed := 1;
      FProgAnim.FAllowProgressAnimate := true;
      FProgOptions.FRoundInt := 16;
    end;
    CProgressPreset.cprBlue: begin
      FProgAnim.aincspeed := 2;
      FAnimation.FAnimations := true;
      FColors.FForeground := 12472848;
      FColors.Background := clWhite;
      FProgAnim.fadesize := 100;
      FProgAnim.FSelectAnimation := atyFade;
      FProgAnim.FCustomRez := false;
      FProgAnim.FCustomY := 0;
      FProgAnim.FCustomX := 0;
      FProgAnim.timerspeed := 1;
      FProgAnim.FAllowProgressAnimate := true;
      FProgOptions.FRoundInt := 16;
    end;
    CProgressPreset.cprModern: begin
      FProgAnim.aincspeed := 2;
      FAnimation.FAnimations := true;
      FColors.FForeground := 12472848;
      FColors.Background := 4144959;
      FProgAnim.fadesize := 100;
      FProgAnim.FSelectAnimation := atyFade;
      FProgAnim.FCustomRez := false;
      FProgAnim.FCustomY := 0;
      FProgAnim.FCustomX := 0;
      FProgAnim.timerspeed := 1;
      FProgAnim.FAllowProgressAnimate := true;
      FProgOptions.FRoundInt := 16;
    end;
    CProgressPreset.cprBeacon: begin
      FProgAnim.aincspeed := 2;
      FPosition := 100;
      FAnimation.FAnimations := false;
      FColors.FForeground := FColors.FForeground;
      FColors.Background := clWhite;
      FProgAnim.fadesize := 200;
      FProgAnim.FSelectAnimation := atyFade;
      FProgAnim.FCustomRez := false;
      FProgAnim.FCustomY := 0;
      FProgAnim.FCustomX := 0;
      FProgAnim.timerspeed := 10;
      FProgAnim.FAllowProgressAnimate := true;
      FProgOptions.FRoundInt := 0;
    end;
  end;
end;

procedure CProgress.SetTrueTransparency(const Value: boolean);
begin
  FTrueTransparency := Value;

  if Value then
    Invalidate;
end;

procedure CProgress.SetValue(pos: integer; jump: boolean);
begin
  if jump then begin
    FPosition := pos;
    if Assigned(FOnChange) then FOnChange(self, FPosition, FMax);
    Paint;
  end else begin
    SetPosition(pos);
  end;
end;

function CProgress.TruncToLimit(tx: string): string;
var
  i: Integer;
  ogr, lmt: integer;
  bonus: string;
begin
  if FProgressText.FIncludePerc then
    bonus := bonus + ' ' + inttostr(FPosition) + '%'
  else
    bonus := '';
  if FProgressText.FWidLimit = -2 then
    lmt := Width
  else
    lmt := FProgressText.FWidLimit;
  ogr := length( tx );
  for i := 0 to ogr do
    if Canvas.TextWidth(tx + bonus) > lmt - 10 then tx := Copy(tx,1,Length ( tx ) - 1);

  Result := tx;
  if length( tx ) <> ogr then
    Result := tx + '...';
end;

{ CProgressAnimate }

procedure CProgressAnimate.ChangeAnimProgSpeed(const Value: integer);
begin
  timerspeed := Value;
  CProgress(Self.Owner).FDrawAnim.Interval := timerspeed;
end;

procedure CProgressAnimate.ChengeAllowAni(const Value: boolean);
begin
  FAllowProgressAnimate := Value;
  CProgress(Self.Owner).FDrawAnim.Enabled := FAllowProgressAnimate;
  CProgress(Self.Owner).Paint;
end;

{ CProgressText }

procedure CProgressText.SetEnableSText(const Value: boolean);
begin
  FSEnable := Value;
  CProgress(Self.Owner).Paint;
end;

procedure CProgressText.SetFnColor(const Value: TColor);
begin
  FTextCol := Value;
  CProgress(Self.Owner).Paint;
end;

procedure CProgressText.SetFnSize(const Value: integer);
begin
  FTextSz := Value;
  CProgress(Self.Owner).Paint;
end;

procedure CProgressText.SetFontNm(const Value: TFontName);
begin
  FTextNm := Value;
  CProgress(Self.Owner).Paint;
end;

procedure CProgressText.SetFtText(const Value: boolean);
begin
  FFitToTx := Value;
  CProgress(Self.Owner).Paint;
end;

procedure CProgressText.SetInclPerc(const Value: boolean);
begin
  FIncludePerc := Value;
  CProgress(Self.Owner).Paint;
end;

procedure CProgressText.SetSText(const Value: string);
begin
  SText := Value;
  CProgress(Self.Owner).Paint;
end;

procedure CProgressText.SetWLimit(const Value: integer);
begin
  FWidLimit := Value;
  CProgress(Self.Owner).Paint;
end;

end.
