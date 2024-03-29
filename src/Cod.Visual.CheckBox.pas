unit Cod.Visual.CheckBox;

interface

uses
  SysUtils,
  Classes,
  Controls,
  Types,
  ExtCtrls,
  Math,
  Forms,
  UITypes,
  WinApi.Windows,
  Graphics,
  Messages,
  Themes,
  StdCtrls,
  Vcl.Styles,
  Cod.ColorUtils,
  Cod.Components,
  Cod.Graphics,
  Cod.Types;

type
  CCheckBox = class;

  CCheckBoxChange = procedure(Sender: CCheckBox; State: TCheckBoxState) of object;

  CCheckBoxState = (csEnter, csLeave, csDown);

  CCheckBoxPresets = (ccpNone, ccpDefault, ccpFluent, ccpMetro, ccpWin32);

  CCheckBoxDrawMode = (cdmFluent, cdmSharp, cdmMinimal, cdmShape, cdmDetalied, cdmWin32);

  CCheckBoxOptions = class(TMPersistent)
    private
      //exceptpreset: boolean;
      FRoundness, FWidth: integer;
      FDrawMode: CCheckBoxDrawMode;
    function Paint: Boolean;
    published
      property DrawStyle: CCheckBoxDrawMode read FDrawMode write FDrawMode stored Paint;
      property Roundness: integer read FRoundNess write FRoundness stored Paint;
      property Width: integer read FWidth write FWidth stored Paint;
      //property PresetException: boolean read exceptpreset write exceptpreset;
  end;

  CCheckBoxAnimation = class(TMPersistent)
    private
      FEnable: boolean;
      FInverval,
      FStep: integer;
    published
      property Enable : boolean read FEnable write FEnable;
      property Interval : integer read FInverval write FInverval;
      property Step : integer read FStep write FStep;
  end;

  CCheckBoxColor = class(TMPersistent)
    private
      FEnter, FLeave, FDown, FChecked, FIndicator: TColor;
      FAutoFont,
      FTrCenter: boolean;
    function Paint : Boolean;
    published
      property AutomaticFontColor : boolean read FAutoFont write FAutoFont;
      property Leave : TColor read FLeave write FLeave stored Paint;
      property Enter : TColor read FEnter write FEnter stored Paint;
      property Down : TColor read FDown write FDown stored Paint;
      property Checked : TColor read FChecked write FChecked stored Paint;
      property CheckIndicator : TColor read FIndicator write FIndicator stored Paint;
      property TransparentCenter : boolean read FTrCenter write FTrCenter;
  end;

  CCheckBoxSize = class(TMPersistent)
    private
      Fx, Fy: integer;
      FProportional: boolean;
      function Paint : Boolean;
    procedure SetProport(const Value: boolean);
    procedure SetX(const Value: integer);
    procedure SetY(const Value: integer);
    published
      property EnableProportional: boolean read FProportional write SetProport stored Paint;
      property Horizontal : integer read Fx write SetX stored Paint;
      property Vertical : integer read Fy write SetY stored Paint;
  end;

  CCheckBoxPreset = class(TMPersistent)
    private
      FrColor : TColor;
      FpKind : CCheckBoxPresets;
      FAutoPen: boolean;
      function Paint : Boolean;
      function ChangeColorSat(clr: TColor; perc: integer): TColor;
    published
      property Color : TColor read FrColor write FrColor stored Paint;
      property Kind : CCheckBoxPresets read FpKind write FpKind stored Paint;
      property PenColorAuto : boolean read FAutoPen write FAutoPen stored Paint;
  end;

  CCheckBoxBorderColor = class(TMPersistent)
    private
      FEnter, FLeave, FDown, FChecked: TColor;
      function Paint : Boolean;
    published
      property Leave : TColor read FLeave write FLeave stored Paint;
      property Enter : TColor read FEnter write FEnter stored Paint;
      property Down : TColor read FDown write FDown stored Paint;
      property Checked : TColor read FChecked write FChecked stored Paint;
  end;

  CCheckBox = class(TCustomTransparentControl)
      constructor Create(AOwner : TComponent); override;
      destructor Destroy; override;
    private
      FAuthor, FSite, FVersion: string;

      FOptions: CCheckBoxOptions;
      FPreset: CCheckBoxPreset;
      FState: TCheckBoxState;
      FColor: CCheckBoxColor;
      FBorderColor: CCheckBoxBorderColor;
      FSize: CCheckBoxSize;
      FAlign: TAlignment;
      MState: CCheckBoxState;
      FAllowGrayed,
      FChecked: boolean;
      FAnimation: CCheckBoxAnimation;
      FText: string;
      //FFont: TFont;
      FProg: integer;
      PrevPen,
      PrevBrush: TColor;
      FCheckBoxChange: CCheckBoxChange;
      FAccent: CAccentColor;
      FIgnorePaintText: boolean;
      FTrueTransparency: boolean;


      Anim: TTimer;

      procedure ApplyPreset(const Value: CCheckBoxPresets);

      procedure InitTimer();
      procedure TimerExec(Sender: TObject);

      function ClrGray(clr: TColor): TColor;

      procedure SetBorderColor(const Value: CCheckBoxBorderColor);
      procedure SetCheck(const Value: boolean);
      procedure SetColor(const Value: CCheckBoxColor);
      procedure SetSize(const Value: CCheckBoxSize);
      procedure SetState(const Value: TCheckBoxState);
      procedure IncCheck(optionalset: boolean = false; state: TCheckBoxState = cbUnchecked; userinteract: boolean = true);
      procedure SetMState(const state: CCheckBoxState);
      procedure SetText(const Value: string);
      procedure SetAlign(const Value: TAlignment);
      procedure SetOptions(const Value: CCheckBoxOptions);
      function MaxOf(nr, max: integer): integer;
      procedure SetAccentColor(const Value: CAccentColor);
      procedure SetTrueTransparency(const Value: boolean);

    protected
      procedure Paint; override;

      procedure PaintCheck;

      procedure Click; override;
      procedure MouseDown(Button : TMouseButton; Shift: TShiftState; X, Y : integer); override;
      procedure MouseUp(Button : TMouseButton; Shift: TShiftState; X, Y : integer); override;
      procedure CMMouseEnter(var Message : TMessage); message CM_MOUSEENTER;
      procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
      procedure KeyPress(var Key: Char); override;
      procedure DoEnter; override;
      procedure DoExit; override;
      procedure ApplyAccentColor;

    published
      procedure SelfRedraw;

      property OnMouseEnter;
      property OnMouseLeave;
      property OnMouseDown;
      property OnMouseUp;
      property OnMouseMove;
      property OnClick;

      property TabStop;
      property TabOrder;

      property OnChange: CCheckBoxChange read FCheckBoxChange write FCheckBoxChange;

      property ParentColor;
      property Color;

      property ParentCTL3D;
      property ParentBiDIMode;
      property ParentBackground;
      property ParentDoubleBuffered;

      property ShowHint;
      property Align;
      property Anchors;
      property Cursor;
      property Visible;
      property Enabled;
      property Constraints;
      property DoubleBuffered;

      property OnKeyDown;
      property OnKeyUp;
      property OnKeyPress;
      property OnEnter;
      property OnExit;

      property ParentFont;

      property PopupMenu;

      property Allignment: TAlignment read FAlign write SetAlign;

      property Text: string read FText write SetText;
      //property Font: TFont read FFont write SetFont;
      property Font;

      property Presets: CCheckBoxPreset read FPreset write FPreset;

      property TrueTransparency: boolean read FTrueTransparency write SetTrueTransparency;
      property AccentColor: CAccentColor read FAccent write SetAccentColor;
      property Animation: CCheckBoxAnimation read FAnimation write FAnimation;
      property Options: CCheckBoxOptions read FOptions write SetOptions;
      property AllowGrayed: boolean read FAllowGrayed write FAllowGrayed;
      property BoxSize: CCheckBoxSize read FSize write SetSize;
      property Colors: CCheckBoxColor read FColor write SetColor;
      property ColorsBorder: CCheckBoxBorderColor read FBorderColor write SetBorderColor;
      property Checked: boolean read FChecked write SetCheck;
      property State: TCheckBoxState read FState write SetState;

      property &&&Author: string Read FAuthor;
      property &&&Site: string Read FSite;
      property &&&Version: string Read FVersion;
    public
      procedure Invalidate; override;
  end;

implementation

{ CCheckbox }

procedure CCheckBox.Click;
begin
  IncCheck;

  //Moved inheritance because clicks would register as Checked = false!
  inherited;
end;

function CCheckBox.ClrGray(clr: TColor): TColor;
var
  RBGval: longint;
  R, G, B: integer;
begin
  RBGval := ColorToRGB(clr);
  R := GetRValue(RBGval);
  G := GetGValue(RBGval);
  B := GetBValue(RBGval);

  R:= (R+G+B) div 3;
  G:= R; B:=R;

  Result := RGB(r,g,b);
end;

procedure CCheckBox.CMMouseEnter(var Message: TMessage);
begin
  SetMState(csEnter);
end;

procedure CCheckBox.CMMouseLeave(var Message: TMessage);
begin
  SetMState(csLeave);
end;

constructor CCheckBox.Create(AOwner: TComponent);
begin
  inherited;
  FAuthor                       := 'Petculescu Codrut';
  FSite                         := 'https://www.codrutsoftware.cf';
  FVersion                      := '1.4';

  interceptmouse:=True;

  FTrueTransparency := true;

  TabStop := true;

  ParentColor := true;
  ParentCTL3D := true;
  ParentDoubleBuffered := true;
  ParentBiDIMode := true;

  FAnimation := CCheckBoxAnimation.Create(Self);
  with FAnimation do begin
    FInverval := 1;
    FStep := 4;
    Enable := true;
  end;

  Anim := TTimer.Create(Self);
  with Anim do begin
    Interval := 1;
    Enabled := false;
    OnTimer := TimerExec;
  end;

  FPreset := CCheckBoxPreset.Create(Self);
  with FPreset do begin
    FPreset.Kind := ccpNone;
    FPreset.Color := $00C57517;
    FPreset.PenColorAuto := true;
  end;

  {FFont := TFont.Create;
  with FFont do begin
    Name := 'Segoe UI';
    Size := 10;
    Color := clWindowText;
  end;}

  FOptions := CCheckBoxOptions.Create(Self);
  with FOptions do begin
    FRoundness := 5;
    FWidth := 3;
    FDrawMode := cdmFluent;
  end;

  FSize := CCheckBoxSize.Create(Self);
  with FSize do begin
    Fx := 16;
    Fy := 16;
    FProportional := true;
  end;

  FColor := CCheckBoxColor.Create(Self);
  with FColor do begin
    FAutoFont := true;
    FLeave := 16250866;
    FEnter := 15658729;
    FDown := 15066593;
    FChecked := 12940567;
    FIndicator := clWhite;
    FTrCenter := true;
  end;

  FBorderColor := CCheckBoxBorderColor.Create(Self);
  with FBorderColor do begin
    FLeave := 9013638;
    FEnter := 9013638;
    FDown := 12434873;
    FChecked := 12940567;
  end;

  FText := 'Checkbox';

  MState := csLeave;

  FAlign := taLeftJustify;

  prevbrush := TStyleManager.ActiveStyle.GetSystemColor(Self.Color);

  FProg := 100;

  FChecked := false;
  FState := cbUnchecked;
  FAllowGrayed := false;

  FAccent := CAccentColor.AccentAdjust;
  ApplyAccentColor;

  Width := 125;
  Height := 35;
end;

destructor CCheckBox.Destroy;
begin
  FreeAndNil(FAnimation);
  Anim.Enabled := false;
  FreeAndNil(Anim);
  FreeAndNil(FOptions);
  FreeAndNil(FColor);
  FreeAndNil(FBorderColor);
  FreeAndNil(FSize);
  //FreeAndNil(FFont);
  inherited;
end;

procedure CCheckBox.DoEnter;
begin
  inherited;
  SetMState(csEnter);
end;

procedure CCheckBox.DoExit;
begin
  inherited;
  SetMState(csLeave);
end;

procedure CCheckBox.IncCheck(optionalset: boolean; state: TCheckBoxState; userinteract: boolean);
begin
  if NOT optionalset then begin

  if FAllowGrayed then begin
    case FState of
      cbUnchecked: FState := cbGrayed;
      cbGrayed: FState := cbChecked;
      cbChecked: FState := cbUnchecked;
    end;
  end else begin
    if FState = cbUnchecked then
      FState := cbChecked
    else
      FState := cbUnchecked;
  end;

  end else
    FState := state;

  if FState = cbChecked then
    FChecked := true
  else
    FChecked := false;

  if not (csReading in Self.ComponentState) then
    if Assigned(FCheckBoxChange) then FCheckBoxChange(Self, FState);

  if userinteract then
    InitTimer;

  PaintCheck;
end;

procedure CCheckBox.InitTimer;
begin
  if NOT FAnimation.Enable then begin
    FProg := 100;
    Exit;
  end;

  FProg := 0;

  PaintCheck;

  Anim.Interval := FAnimation.Interval;
  Anim.Enabled := true;
end;

procedure CCheckBox.Invalidate;
begin
  inherited;
  ApplyAccentColor;

  FIgnorePaintText := false;
  Paint;

  if FSize.FProportional then begin
    if FSize.Fx > FSize.Fy then
      FSize.Fy := FSize.Fx
    else
      FSize.Fx := FSize.Fy;
  end;
end;

procedure CCheckBox.KeyPress(var Key: Char);
begin
  inherited;
  if key = #13 then begin
    IncCheck();
  end;
end;

function CCheckBox.MaxOf(nr, max: integer): integer;
begin
  if nr > max then
    nr := max;

  Result := nr;
end;

procedure CCheckBox.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: integer);
begin
  inherited;
  try
    Self.SetFocus;
  except
    RaiseLastOSError;
  end;
  SetMState(csDown);
end;

procedure CCheckBox.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: integer);
begin
  inherited;
  SetMState(csEnter);
end;

procedure CCheckBox.Paint;
var
  workon: TBitMap;
  cbtop,
  cbleft,
  cbtextleft,
  tmp,
  tmp2,
  cbtexttop: integer;
  izn: TRect;
  chk: TRoundRect;
begin
  inherited;
  ApplyAccentColor;
  ApplyPreset(FPreset.Kind);

  cbleft := 0;
  cbtextleft := 0;
  cbtexttop := 0;

  workon := TBitMap.Create;
  workon.Width := Width;
  workon.Height := Height;
  try
  with workon.Canvas do begin
    Font.Assign(Self.Font);

    cbtop := Height div 2 - round(FSize.Fy / 2);

    case FAlign of
      taLeftJustify: begin
        cbleft := FOptions.Width;
        cbtextleft := cbleft + FSize.Fx + round(Self.Font.Size / 2);
      end;
      taRightJustify: begin
        cbleft := Width - FSize.Fx - FOptions.Width;
        cbtextleft := 0;
      end;
      taCenter: begin
        cbleft := Width div 2 - (TextWidth(FText) + FSize.Fx) div 2;
        cbtextleft := cbleft + FSize.Fx + round(Self.Font.Size / 2);
      end;
    end;

    Brush.Color := TStyleManager.ActiveStyle.GetSystemColor(Color);
    FillRect(cliprect);

    //Brush.Style := bsClear;
    Pen.Width := FOptions.FWidth;
    case MState of
      csEnter: begin
        Pen.Color := FBorderColor.FEnter;
        Brush.Color := FColor.FEnter;
      end;
      csLeave: begin
        Pen.Color := FBorderColor.FLeave;
        Brush.Color := FColor.FLeave;
      end;
      csDown: begin
        Pen.Color := FBorderColor.FDown;
        Brush.Color := FColor.FDown;
      end;
    end;
    

    if FColor.FTrCenter then
      Brush.Color := TStyleManager.ActiveStyle.GetSystemColor(Self.Color);

    if FState <> cbUnchecked then
    begin
      Pen.Color := FBorderColor.FChecked;
      Brush.Color := FColor.FChecked;

      if MState = csEnter then begin
        Brush.Color := FPreset.ChangeColorSat(Brush.Color, -15);
        Pen.Color := FPreset.ChangeColorSat(Pen.Color, -15);
      end;
    end;

    if FProg = 100 then begin
      prevbrush := Brush.Color;
      prevpen := Pen.Color;
    end;

    Pen.Color := ColorBlend(Pen.Color, PrevPen, FProg);
    Brush.Color := ColorBlend(Brush.Color, PrevBrush, FProg);

    if NOT Self.Enabled then
    begin
      Pen.Color := ClrGray(Pen.Color);
      Brush.Color := ClrGray(Brush.Color);
    end;

    chk.Create(Rect(cbleft, cbtop, cbleft + FSize.Fx, cbtop + FSize.Fy), FOptions.Roundness);
    RoundRect(chk.Left, chk.Top, chk.Right, chk.Bottom, chk.RoundX, chk.RoundY);

    if FOptions.FRoundness > 0 then
        chk.SetRoundness(chk.RoundY + 1);

    if FColor.FAutoFont then
      Font.Color := TStyleManager.ActiveStyle.GetSystemColor(Font.Color);

    cbtexttop := cbtop + round(FSize.Fy / 2.5) - TextHeight(FText) div 2;
    //cbtexttop := Height div 2 - TextHeight(FText) div 2;

    Brush.Style := bsClear;
    TextOut(cbtextleft, cbtexttop, FText);

    izn := Rect(cbleft + FOptions.FWidth div 2, cbtop + FOptions.FWidth div 2, cbleft + FSize.Fx - FOptions.FWidth div 2, cbtop + FSize.Fy - FOptions.FWidth div 2);


    Brush.Style := bsClear;
    Pen.Width := (FSize.Fx + FSize.Fy) div 16;
    if Pen.Width <= 1 then Pen.Width := 2;
    Pen.Color := FColor.FIndicator;
    case Fstate of
      cbUnchecked: begin
        case FOptions.FDrawMode of
          cdmShape: begin
            //Nothing
          end;
          cdmFluent: begin
            //Nothing
          end;
          cdmMinimal: begin
            //nothing
          end;
          cdmSharp: begin
            //Nothing
          end;
          cdmDetalied: begin
            Pen.Color := FBorderColor.FLeave;
            tmp := round(izn.BottomRight.X - izn.Width / 6) - (izn.TopLeft.X + izn.Width div 6);
            tmp2 := (izn.BottomRight.Y - izn.Height div 4) - (izn.TopLeft.Y + izn.Height div 6);
            if FProg <= 50 then begin
              moveto(izn.TopLeft.X + izn.Width div 6, izn.TopLeft.Y + izn.Height div 6);

              lineto(izn.TopLeft.X + izn.Width div 6 + trunc(MaxOf(FProg, 50)/50 * tmp), izn.TopLeft.Y + izn.Height div 6 + trunc(MaxOf(FProg, 50)/50 * tmp2));
            end else
            begin
              moveto(izn.TopLeft.X + izn.Width div 6, izn.TopLeft.Y + izn.Height div 6);
              lineto(izn.BottomRight.X - izn.Width div 6, izn.BottomRight.Y - izn.Height div 4);

              moveto(izn.TopLeft.X + izn.Width div 6, izn.BottomRight.Y - izn.Height div 4);
              lineto(izn.TopLeft.X + izn.Width div 6 + trunc((FProg - 50) / 50 * tmp), izn.BottomRight.Y - izn.Height div 4 - trunc((FProg - 50) / 50 * tmp2) );
            end;
          end;
          cdmWin32: begin
            //Nothing
          end;
        end;
      end;
      cbChecked: begin
        case FOptions.FDrawMode of
          cdmShape: begin
            Brush.Color := pen.Color;
            brush.Style := bsSolid;
            tmp := (izn.BottomRight.X - izn.Width div 4) - (izn.TopLeft.X + izn.Width div 3);
            tmp2 := trunc(tmp - MaxOf(FProg + 50,100) / 100 * tmp);
            Ellipse(round(izn.TopLeft.X + izn.Width / 4) + tmp2, round(izn.TopLeft.Y + izn.Height / 4) + tmp2,
                      izn.BottomRight.X - izn.Width div 4 - tmp2, izn.BottomRight.Y - izn.Height div 4  -tmp2);
          end;
          cdmFluent: begin
            moveto(izn.TopLeft.X + izn.Width div 8, izn.TopLeft.Y + izn.Height div 2);
            if FProg <= 50 then 
            begin
               tmp := (izn.BottomRight.X - trunc(izn.Width * 2.9/4)) - (izn.TopLeft.X + izn.Width div 8);
               tmp2 := (izn.BottomRight.Y - trunc(izn.Height * 1/3)) - (izn.TopLeft.Y + izn.Height div 2);
               lineto(izn.TopLeft.X + izn.Width div 8 + trunc(FProg / 50 * tmp) , izn.TopLeft.Y + izn.Height div 2 + trunc(FProg / 50 * tmp2));
            end else
            begin
              lineto(izn.BottomRight.X - trunc(izn.Width * 2.9/4), izn.BottomRight.Y - trunc(izn.Height * 1/3));

              tmp := (izn.BottomRight.X - izn.Width div 6) - (izn.BottomRight.X - trunc(izn.Width * 2.9/4));
              tmp2 := (izn.TopLeft.Y + izn.Height div 6) - (izn.BottomRight.Y - trunc(izn.Height * 1/3));
              
              lineto(izn.BottomRight.X - trunc(izn.Width * 2.9/4) + trunc((FProg - 50) / 50 * tmp), izn.BottomRight.Y - trunc(izn.Height * 1/3) + trunc((FProg - 50) / 50 * tmp2));
            end;
          end;
          cdmMinimal: begin
            //nothing
          end;
          cdmSharp: begin
            moveto(izn.TopLeft.X + izn.Width div 8, izn.TopLeft.Y + izn.Height div 2);
            if FProg <= 50 then 
            begin
               tmp := (izn.BottomRight.X - trunc(izn.Width * 2.9/4)) - (izn.TopLeft.X + izn.Width div 8);
               tmp2 := (izn.BottomRight.Y - trunc(izn.Height * 1/3)) - (izn.TopLeft.Y + izn.Height div 2);
               lineto(izn.TopLeft.X + izn.Width div 8 + trunc(FProg / 50 * tmp) , izn.TopLeft.Y + izn.Height div 2 + trunc(FProg / 50 * tmp2));
            end else
            begin
              lineto(izn.BottomRight.X - trunc(izn.Width * 2.9/4), izn.BottomRight.Y - trunc(izn.Height * 1/3));

              tmp := (izn.BottomRight.X - izn.Width div 6) - (izn.BottomRight.X - trunc(izn.Width * 2.9/4));
              tmp2 := (izn.TopLeft.Y + izn.Height div 6) - (izn.BottomRight.Y - trunc(izn.Height * 1/3));

              lineto(izn.BottomRight.X - trunc(izn.Width * 2.9/4) + trunc((FProg - 50) / 50 * tmp), izn.BottomRight.Y - trunc(izn.Height * 1/3) + trunc((FProg - 50) / 50 * tmp2));
            end;
          end;
          cdmDetalied: begin
            moveto(izn.TopLeft.X + izn.Width div 8, izn.TopLeft.Y + izn.Height div 2);
            if FProg <= 50 then 
            begin
               tmp := (izn.BottomRight.X - trunc(izn.Width * 2.9/4)) - (izn.TopLeft.X + izn.Width div 8);
               tmp2 := (izn.BottomRight.Y - trunc(izn.Height * 1/3)) - (izn.TopLeft.Y + izn.Height div 2);
               lineto(izn.TopLeft.X + izn.Width div 8 + trunc(FProg / 50 * tmp) , izn.TopLeft.Y + izn.Height div 2 + trunc(FProg / 50 * tmp2));
            end else
            begin
              lineto(izn.BottomRight.X - trunc(izn.Width * 2.9/4), izn.BottomRight.Y - trunc(izn.Height * 1/3));

              tmp := (izn.BottomRight.X - izn.Width div 6) - (izn.BottomRight.X - trunc(izn.Width * 2.9/4));
              tmp2 := (izn.TopLeft.Y + izn.Height div 6) - (izn.BottomRight.Y - trunc(izn.Height * 1/3));
              
              lineto(izn.BottomRight.X - trunc(izn.Width * 2.9/4) + trunc((FProg - 50) / 50 * tmp), izn.BottomRight.Y - trunc(izn.Height * 1/3) + trunc((FProg - 50) / 50 * tmp2));
            end;
          end;
          cdmWin32: begin
            moveto(izn.TopLeft.X + izn.Width div 8, izn.TopLeft.Y + izn.Height div 2);
            if FProg <= 50 then 
            begin
               tmp := (izn.BottomRight.X - trunc(izn.Width * 2.9/4)) - (izn.TopLeft.X + izn.Width div 8);
               tmp2 := (izn.BottomRight.Y - trunc(izn.Height * 1/3)) - (izn.TopLeft.Y + izn.Height div 2);
               lineto(izn.TopLeft.X + izn.Width div 8 + trunc(FProg / 50 * tmp) , izn.TopLeft.Y + izn.Height div 2 + trunc(FProg / 50 * tmp2));
            end else
            begin
              lineto(izn.BottomRight.X - trunc(izn.Width * 2.9/4), izn.BottomRight.Y - trunc(izn.Height * 1/3));

              tmp := (izn.BottomRight.X - izn.Width div 6) - (izn.BottomRight.X - trunc(izn.Width * 2.9/4));
              tmp2 := (izn.TopLeft.Y + izn.Height div 6) - (izn.BottomRight.Y - trunc(izn.Height * 1/3));
              
              lineto(izn.BottomRight.X - trunc(izn.Width * 2.9/4) + trunc((FProg - 50) / 50 * tmp), izn.BottomRight.Y - trunc(izn.Height * 1/3) + trunc((FProg - 50) / 50 * tmp2));
            end;
          end;
        end;
      end;
      cbGrayed: begin
        case FOptions.FDrawMode of
          cdmShape: begin
            Brush.Color := pen.Color;
            brush.Style := bsSolid;
            tmp := (izn.BottomRight.X - izn.Width div 4) - (izn.TopLeft.X + izn.Width div 3);
            Rectangle(round(izn.TopLeft.X + izn.Width / 4), round(izn.TopLeft.Y + izn.Height / 4),
                      izn.TopLeft.X + izn.Width div 3 + trunc(FProg / 100 * tmp), izn.BottomRight.Y - izn.Height div 4);
          end;
          cdmFluent: begin
            Brush.Color := pen.Color;
            brush.Style := bsSolid;
            tmp := (izn.BottomRight.X - izn.Width div 4) - (izn.TopLeft.X + izn.Width div 3);
            tmp2 := trunc(tmp - MaxOf(FProg + 50,100) / 100 * tmp);
            Rectangle(round(izn.TopLeft.X + izn.Width / 4) + tmp2, round(izn.TopLeft.Y + izn.Height / 4) + tmp2,
                      izn.BottomRight.X - izn.Width div 4 - tmp2, izn.BottomRight.Y - izn.Height div 4  -tmp2);
          end;
          cdmMinimal: begin
            moveto(izn.TopLeft.X + izn.Width div 4, izn.TopLeft.Y + izn.Height div 2);
            if FProg >= 50 then
              lineto(izn.BottomRight.X - izn.Width div 3, izn.BottomRight.Y - izn.Height div 2);
          end;
          cdmSharp: begin
            Brush.Color := pen.Color;
            brush.Style := bsSolid;
            tmp := (izn.BottomRight.X - izn.Width div 8) - (izn.TopLeft.X + izn.Width div 6);
            Rectangle(izn.TopLeft.X + izn.Width div 6, izn.TopLeft.Y + round(izn.Height / 1.9),
              izn.TopLeft.X + round(izn.Width / 8) + round(FProg / 100 * tmp), izn.BottomRight.Y - round(izn.Height / 2.2));
          end;
          cdmDetalied: begin
            Brush.Color := pen.Color;
            brush.Style := bsSolid;
            tmp := (izn.BottomRight.X - izn.Width div 8) - (izn.TopLeft.X + izn.Width div 6);

            RoundRect(izn.TopLeft.X + round(izn.Width / 6), izn.TopLeft.Y + round(izn.Height / 2.5) - round(Pen.Width / 3),
              izn.TopLeft.X + round(izn.Width / 8) + round(FProg / 100 * tmp), izn.BottomRight.Y - round(izn.Height / 1.3) + round(Pen.Width / 2), round(Pen.Width / 2), round(Pen.Width / 2));

            RoundRect(izn.TopLeft.X + round(izn.Width / 6), izn.TopLeft.Y + round(izn.Height / 1.3) - round(Pen.Width / 3),
              izn.TopLeft.X + round(izn.Width / 8) + round(FProg / 100 * tmp), izn.BottomRight.Y - round(izn.Height / 2.4) + round(Pen.Width / 2), round(Pen.Width / 2), round(Pen.Width / 2));
          end;
          cdmWin32: begin
            Brush.Color := pen.Color;
            brush.Style := bsSolid;
            tmp := (izn.BottomRight.X - izn.Width div 8) - (izn.TopLeft.X + izn.Width div 6);
            RoundRect(izn.TopLeft.X + izn.Width div 6, izn.TopLeft.Y + round(izn.Height / 1.9),
              izn.TopLeft.X + round(izn.Width / 8) + round(FProg / 100 * tmp), izn.BottomRight.Y - round(izn.Height / 2.2), round(Pen.Width / 1), round(Pen.Width / 1));
          end;
        end;
      end;
    end;

  end;
  finally
    // Finalise
   if FTrueTransparency then
    begin
       CopyRoundRect(workon.Canvas, chk, Canvas, chk.Rect);

       {if NOT FIgnorePaintText then     } // FIX BUGGY MESS
       with inherited canvas do begin
          Font.Assign(Self.Font);
          Brush.Style := bsClear;
          TextOut(cbtextleft, cbtexttop, FText);
       end;
    end
      else
        with inherited Canvas do
          CopyRect(Rect(0,0,width,height), workon.Canvas, workon.canvas.ClipRect);
      
   workon.Free;
  end;

end;

procedure CCheckBox.PaintCheck;
begin
  FIgnorePaintText := true;
  Paint;
  FIgnorePaintText := false;
end;

procedure CCheckBox.SelfRedraw;
begin
  Paint;
end;

procedure CCheckBox.SetAccentColor(const Value: CAccentColor);
begin
  FAccent := Value;

  if Value <> CAccentColor.None then
    ApplyAccentColor;

  PaintCheck;
end;

procedure CCheckBox.SetAlign(const Value: TAlignment);
begin
  FAlign := Value;
  Invalidate;
end;

procedure CCheckBox.SetBorderColor(const Value: CCheckBoxBorderColor);
begin
  FBorderColor := Value;
  CCheckBox(Self).PaintCheck;
end;

procedure CCheckBox.SetCheck(const Value: boolean);
begin
  FChecked := Value;

  if FChecked then
    FState := cbChecked
  else
    FState := cbUnchecked;

  CCheckBox(Self).PaintCheck;
end;

procedure CCheckBox.SetColor(const Value: CCheckBoxColor);
begin
  FColor := Value;
  CCheckBox(Self).PaintCheck;
end;

procedure CCheckBox.SetMState(const state: CCheckBoxState);
begin
  MState := state;
  PaintCheck;
end;

procedure CCheckBox.SetOptions(const Value: CCheckBoxOptions);
begin
  FOptions := Value;
  PaintCheck;
end;

procedure CCheckBox.SetSize(const Value: CCheckBoxSize);
begin
  FSize := Value;
  CCheckBox(Self).PaintCheck;
end;

procedure CCheckBox.SetState(const Value: TCheckBoxState);
begin
  IncCheck(true, Value, false);
  CCheckBox(Self).PaintCheck;
end;

procedure CCheckBox.SetText(const Value: string);
begin
  FText := Value;
  Invalidate;
end;

procedure CCheckBox.SetTrueTransparency(const Value: boolean);
begin
  FTrueTransparency := Value;

  if Value then
    Invalidate;
end;

procedure CCheckBox.TimerExec(Sender: TObject);
begin
  inc(FProg,FAnimation.FStep);

  if FProg >= 100 then begin
    Anim.Enabled := false;
    FProg := 100;
  end;

  PaintCheck;
end;

procedure CCheckBox.ApplyAccentColor;
var
  AccColor: TColor;
begin
  if FAccent = CAccentColor.None then
    Exit;

  AccColor := GetAccentColor(FAccent);

  FColor.FChecked := AccColor;
  FBorderColor.FChecked := AccColor;
end;

procedure CCheckBox.ApplyPreset(const Value: CCheckBoxPresets);
begin
  FPreset.Kind := Value;

  if FPreset.Kind = ccpNone then Exit;

  if FPreset.PenColorAuto then begin
    FColor.FChecked := FPreset.Color;
    FColor.CheckIndicator := clWhite;
    FColor.FDown := $00E5E5E1;
    FColor.FEnter := $00EEEEE9;
    FColor.FLeave := $00F7F7F2;

    FBorderColor.FChecked := FPreset.Color;
    FBorderColor.FDown := $00BDBDB9;
    FBorderColor.FEnter := $00898986;
    FBorderColor.FLeave := $00898986;
  end;


  case FPreset.Kind of
    ccpDefault: begin
      FAnimation.FStep := 4;
      FAnimation.Enable := true;
      FAnimation.Interval := 1;
      FSize.FProportional := true;
      FSize.Fx := 16;
      FSize.Fy := 16;
      Self.Font.Name := 'Segoe UI';
      Self.Font.Size := 10;
      FOptions.Roundness := 5;
      FOptions.Width := 3;
      FOptions.FDrawMode := cdmFluent;
      FColor.FTrCenter := true;
      FColor.FAutoFont := true;
    end;
    ccpFluent: begin
      FAnimation.FStep := 4;
      FAnimation.Enable := true;
      FAnimation.Interval := 1;
      FSize.FProportional := true;
      FSize.Fx := 20;
      FSize.Fy := 20;
      Self.Font.Name := 'Segoe UI';
      Self.Font.Size := 12;
      FOptions.Roundness := 6;
      FOptions.Width := 3;
      FOptions.FDrawMode := cdmFluent;
      FColor.FTrCenter := true;
      FColor.FAutoFont := true;
    end;
    ccpMetro: begin
      FAnimation.FStep := 4;
      FAnimation.Enable := true;
      FAnimation.Interval := 1;
      FSize.FProportional := true;
      FSize.Fx := 20;
      FSize.Fy := 20;
      Self.Font.Name := 'Segoe UI';
      Self.Font.Size := 10;
      FOptions.Roundness := 0;
      FOptions.Width := 3;
      FOptions.FDrawMode := cdmSharp;
      FColor.FTrCenter := true;
      FColor.FAutoFont := true;
    end;
    ccpWin32: begin
      FAnimation.FStep := 4;
      FAnimation.Enable := true;
      FAnimation.Interval := 1;
      FSize.FProportional := true;
      FSize.Fx := 16;
      FSize.Fy := 16;
      Self.Font.Name := 'Segoe UI';
      Self.Font.Size := 8;
      FOptions.Roundness := 2;
      FOptions.Width := 1;
      FOptions.FDrawMode := cdmWin32;
      FColor.FTrCenter := true;
      FColor.FAutoFont := true;
    end;
  end;
end;

{ CCheckBoxColor }

function CCheckBoxColor.Paint: Boolean;
begin
  if Self.Owner is CCheckBox then begin
    CCheckBox(Self.Owner).Paint;
    Result := True;
  end else Result := False;
end;

{ CCheckBoxSize }

function CCheckBoxSize.Paint: Boolean;
begin
  if Self.Owner is CCheckBox then begin
    CCheckBox(Self.Owner).Paint;
    Result := True;
  end else Result := False;
end;

procedure CCheckBoxSize.SetProport(const Value: boolean);
begin
  FProportional := Value;

  if FProportional then begin
    if Fx > Fy then
      Fy := Fx
    else
      Fx := Fy;
  end;
end;

procedure CCheckBoxSize.SetX(const Value: integer);
begin
  Fx := Value;
end;

procedure CCheckBoxSize.SetY(const Value: integer);
begin
  Fy := Value;
end;

{ CCheckBoxBorderColor }

function CCheckBoxBorderColor.Paint: Boolean;
begin
  if Self.Owner is CCheckBox then begin
    CCheckBox(Self.Owner).Paint;
    Result := True;
  end else Result := False;
end;

{ CCheckBoxOptions }

function CCheckBoxOptions.Paint: Boolean;
begin
  if Self.Owner is CCheckBox then begin
    CCheckBox(Self.Owner).Paint;
    Result := True;
  end else Result := False;
end;

{ CCheckBoxPreset }

function CCheckBoxPreset.ChangeColorSat(clr: TColor; perc: integer): TColor;
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

function CCheckBoxPreset.Paint: Boolean;
begin
  if Self.Owner is CCheckBox then begin
    CCheckBox(Self.Owner).Paint;
    Result := True;
  end else Result := False;
end;

end.
