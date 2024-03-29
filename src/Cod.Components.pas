unit Cod.Components;

{$SCOPEDENUMS ON}

interface

uses
  Types, UITypes, Classes, System.UIConsts, Vcl.Graphics,
  Variants, System.Win.Registry, Winapi.Windows, SysUtils, System.DateUtils,
  Cod.Registry, TypInfo;

  type
    CAccentColor = (None, Accent, AccentAdjust, AccentCustom);
    CCurrentTheme = (Auto, Light, Dark);
    CControlState = (Leave, Enter, Down);

    CComponentOnPaint = procedure(Sender: TObject) of object;

    CControl = interface
      //['{5098EF5C-0451-490D-A0B2-24C414F21A24}']

      procedure UpdateAccent;
    end;

    TMPersistent = class(TPersistent)
      Owner : TPersistent;
      constructor Create(AOwner : TPersistent); overload; virtual;

      procedure Assign(Source: TPersistent); override;
    end;

    function GetColorSat(color: TColor; ofing: integer = 255): integer;
    function ChangeColorSat(clr: TColor; perc: integer): TColor;

    function GetAccentColor(Accent: CAccentColor): TColor;
    function GetTheme: CCurrentTheme;
    procedure SetTheme(ChangeTo: CCurrentTheme);
    procedure SyncAccentColor;
    function IsAppsUseDarkTheme: Boolean;

    procedure CheckForUpdateAccent;

  var
    CurrentTheme: CCurrentTheme;
    AccentColor: TColor;
    AdjustedAccentColor: TColor;
    CustomAccentColor: TColor = $00C57517;

    OnUpdateAccentColor: procedure;

    LastCheck: TDateTime;
    JustStarted: boolean;

implementation

function IsAppsUseDarkTheme: Boolean;
var
  R: TRegistry;
begin
  Result := False;
  R := TRegistry.Create;
  try
    R.RootKey := HKEY_CURRENT_USER;
    if R.OpenKeyReadOnly('Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\') and R.ValueExists('AppsUseLightTheme') then begin
      Result := R.ReadInteger('AppsUseLightTheme') <> 1;
    end;
  finally
    R.Free;
  end;
end;

function GetColorSat(color: TColor; ofing: integer): integer;
var
  l1, l2, l3: real;
  R, G, B: integer;
begin
  R := GetRValue(color);
  G := GetGValue(color);
  B := GetBValue(color);

  l1 := R / 255 * ofing;
  l2 := G / 255 * ofing;
  l3 := B / 255 * ofing;

  Result := trunc((l1 + l2 + l3)/3);
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

procedure CheckForUpdateAccent;
begin
  if JustStarted or (SecondsBetween(Now, LastCheck) > 30) then
    SyncAccentColor
end;

function GetAccentColor(Accent: CAccentColor): TColor;
begin
  Result := 13924352;
  CheckForUpdateAccent;

  case Accent of
    CAccentColor.Accent: Result := AccentColor;
    CAccentColor.AccentAdjust: Result := AdjustedAccentColor;
    CAccentColor.AccentCustom: Result := CustomAccentColor;
  end;
end;

function GetTheme: CCurrentTheme;
begin
  Result := CurrentTheme;
end;

procedure SetTheme(ChangeTo: CCurrentTheme);
begin
  if changeto = CurrentTheme then
    Exit;

  CurrentTheme := changeto;

  SyncAccentColor;
end;

procedure SyncAccentColor;
var
  R: TRegistry;
  Value: Cardinal;
  CSat: integer;
  //themedark: boolean;
begin
  LastCheck := Now;

  AccentColor := $D77800;  //  Default value on error
  R := TRegistry.Create;
  try
    R.RootKey := HKEY_CURRENT_USER;
    if R.OpenKeyReadOnly('Software\Microsoft\Windows\DWM\') and R.ValueExists('AccentColor') then begin
      Value := R.ReadCardinal('AccentColor');

      AccentColor := Value mod $FF000000; //  ARGB to RGB
      AdjustedAccentColor := AccentColor;
    end;
  finally
    R.Free;
  end;

  CSat := GetColorSat(AccentColor, 255);

  {themedark := false;
  if CurrentTheme = ctAuto then
    themedark := IsAppsUseDarkTheme
     else
      if CurrentTheme = ctDark then
        themedark := true;  }


  //if themedark then
  if CSat < 110 then
    AdjustedAccentColor := ChangeColorSat(AccentColor, 110 - CSat);

  if CSat > 155 then
    AdjustedAccentColor := ChangeColorSat(AccentColor, (CSat - 155) * -1);

  // Prop
  if Assigned(OnUpdateAccentColor) then
    OnUpdateAccentColor;
end;

{ TMPersistent }

function PropertyExists(Instance: TObject; const PropName: string): boolean; overload;
var
  AProp: PPropInfo;
begin
  AProp := GetPropInfo(PTypeInfo(Instance.ClassInfo), PropName);

  Result := AProp <> nil;
end;

procedure TMPersistent.Assign(Source: TPersistent);
var
  APropName: string;
  PropList: PPropList;
  PropCount, i: Integer;
begin
  if Source is TMPersistent then
  begin
    PropCount := GetPropList(Source.ClassInfo, tkProperties, nil);
    if PropCount > 0 then
    begin
      GetMem(PropList, PropCount * SizeOf(PPropInfo));
      try
        GetPropList(Source.ClassInfo, tkProperties, PropList);
        for i := 0 to PropCount - 1 do
          begin
            APropName := string(PropList^[i]^.Name);
            if PropertyExists(Self, APropName) then
              SetPropValue(Self, APropName, GetPropValue(Source, string(PropList^[i]^.Name)));
          end;
      finally
        FreeMem(PropList);
      end;
    end;
  end
  else
    inherited Assign(Source);
end;

constructor TMPersistent.Create(AOwner: TPersistent);
begin
  inherited Create;
  Owner := AOwner;
end;

end.
