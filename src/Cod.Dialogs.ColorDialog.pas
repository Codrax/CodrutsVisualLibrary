{***********************************************************}
{                    Codruts Color Dialog                   }
{                                                           }
{                         version 1.0                       }
{                           RELEASE                         }
{                                                           }
{                                                           }
{                                                           }
{                                                           }
{                                                           }
{                   -- WORK IN PROGRESS --                  }
{***********************************************************}

unit Cod.Dialogs.ColorDialog;

interface
  uses
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Forms,
  System.SysUtils,
  Cod.Visual.Button,
  Vcl.StdCtrls,
  Cod.Visual.ColorBright,
  Cod.Visual.ColorWheel,
  Cod.Visual.ColorBox,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Registry,
  Cod.ColorUtils,
  Vcl.Dialogs;
  type
    CColorDialog = class(TComponent)
    public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;

    private
      FAuthor, FSite, FVersion: string;
      UI: TForm;
      FColor: TColor;

      CR,
      CG,
      CB,
      CHEX,
      CDec: TEdit;
      CLbr: CColorBright;
      CBx: CColorBox;
      clwh: CColorWheel;

      noact: integer;

      FTitle: string;
      FAdvanced: boolean;
      FCHistory: array[1..5] of TColor;

      procedure ClickHistory(Sender: TObject);
      procedure ChangeIColor(Sender: CColorBright; Color: TColor; X, Y: Integer);
      procedure TextOnExit(Sender: TObject);
      procedure EnterOnRGB(Sender: TObject; var Key: Word; Shift: TShiftState);
      procedure EnterOnDec(Sender: TObject; var Key: Word; Shift: TShiftState);
      procedure EnterOnHEX(Sender: TObject; var Key: Word; Shift: TShiftState);
      procedure AddNewColorToHistory(clr: TColor);
    published
      property Author: string Read FAuthor;
      property Site: string Read FSite;
      property Version: string Read FVersion;

      property Color: TColor read FColor write FColor;
      property Title: string read FTitle write FTitle;

      property Advanced: boolean read FAdvanced write FAdvanced;

      function Execute: boolean; overload;
      function GetColor(Default: TColor = 12940567): TColor;
      procedure ModifyColor(var objectcolor: TColor);
    public
      function Execute(defaultcolor: TColor): boolean; overload;
    end;

implementation

{ WinReg }

var
  regmode: integer = 0;

procedure CColorDialog.AddNewColorToHistory(clr: TColor);
var
  i: integer;
begin
  for i := 5 downto 2 do
   FCHistory[i] := FCHistory[i - 1];

  FCHistory[1] := clr;
end;

procedure CColorDialog.ChangeIColor(Sender: CColorBright; Color: TColor; X,
  Y: Integer);
var
  RGB: CRGB;
begin
  CBx.ItemColor := Color;

  //Update Edits
  if FAdvanced then
  begin
    RGB.R := GetRValue(CBx.ItemColor);
    RGB.G := GetGValue(CBx.ItemColor);
    RGB.B := GetBValue(CBx.ItemColor);


    if noact <> 1 then
    begin

    if CR <> nil then
      CR.Text := inttostr(RGB.R);
    if CG <> nil then
      CG.Text := inttostr(RGB.G);
    if CB <> nil then
      CB.Text := inttostr(RGB.B);

    end;

    if (CHEX <> nil) and (noact <> 2) then
      CHEX.Text := ColorToHEX(CBx.ItemColor);

    if (CDec <> nil) and (noact <> 3) then
      CDec.Text := inttostr(ColorToRGB(CBx.ItemColor));
  end;
end;

procedure CColorDialog.ClickHistory(Sender: TObject);
begin
  CBx.ItemColor := FCHistory[CColorBox(Sender).Tag];
  CLbr.PureColor := FCHistory[CColorBox(Sender).Tag];
  CLbr.ChangeX(CLbr.width div 2);
  clwh.Color := FCHistory[CColorBox(Sender).Tag];
end;

constructor CColorDialog.Create(AOwner: TComponent);
var
  I: Integer;
begin
  inherited Create(AOwner);
  FAuthor                       := 'Petculescu Codrut';
  FSite                         := 'https://www.codrutsoftware.cf';
  FVersion                      := '1.0';

  FTitle := 'Color Picker';

  FAdvanced := true;

  for I := 1 to 5 do
    FCHistory[i] := 1840393;
end;

destructor CColorDialog.Destroy;
begin
  inherited Destroy;
end;

procedure CColorDialog.EnterOnDec(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if CDec.Text = '' then
    Exit;

  CBx.ItemColor := strtoint(TEdit(Sender).Text);
  clwh.Color := CBx.ItemColor;
  CLbr.PureColor := CBx.ItemColor;

  noact := 3;
  ChangeIColor(nil, CBx.ItemColor, 0, 0);
end;

procedure CColorDialog.EnterOnHEX(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if CHEX.Text = '' then
    Exit;

  CBx.ItemColor := HEXToColor(TEdit(Sender).Text);
  clwh.Color := CBx.ItemColor;
  CLbr.PureColor := CBx.ItemColor;

  noact := 2;
  ChangeIColor(nil, CBx.ItemColor, 0, 0);
end;

procedure CColorDialog.EnterOnRGB(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (CR.Text = '') or (CG.Text = '') or (CB.Text = '') then
    Exit;

  // Num check
  if (strtoint(CR.Text) < 0)  then CR.Text := '0';
  if (strtoint(CG.Text) > 255)  then CR.Text := '255';

  if (strtoint(CG.Text) < 0)  then CG.Text := '0';
  if (strtoint(CG.Text) > 255)  then CG.Text := '255';

  if (strtoint(CB.Text) < 0)  then CB.Text := '0';
  if (strtoint(CB.Text) > 255)  then CB.Text := '255';


  CBx.ItemColor := RGB(strtoint(CR.Text), strtoint(CG.Text), strtoint(CB.Text));
  clwh.Color := CBx.ItemColor;
  CLbr.PureColor := CBx.ItemColor;

  noact := 1;
  ChangeIColor(nil, CBx.ItemColor, 0, 0);
end;

function CColorDialog.Execute(defaultcolor: TColor): boolean;
begin
    Self.Color := defaultcolor;

  Result := Execute;
end;

function CColorDialog.Execute: boolean;
begin
  UI := TForm.Create(Application);
  with UI do begin

    Width := 600;
    Height := 300;
    Position := poDesigned;
    Left := Screen.Width div 2 - UI.Width div 2;
    Top := Screen.Height div 2 - UI.Height div 2;

    Caption := FTitle;

    BorderIcons := [biSystemMenu];

    BorderStyle := bsSingle;

    with TLabel.Create(UI) do begin
      Parent := UI;

      Caption := FTitle;

      Font.Style := [fsBold];
      Font.Name := 'Segoe UI';
      Font.Size := 18;

      Top := 10;
      Left := 10;
    end;

    with TLabel.Create(UI) do begin
      Parent := UI;

      Caption := '                                                                                  ';

      Font.Style := [fsUnderline];
      Font.Name := 'Segoe UI';
      Font.Size := 18;

      Top := 10;
      Left := 10;
    end;

    with TLabel.Create(UI) do begin
      Parent := UI;

      Caption := 'Loading...';

      Font.Name := 'Segoe UI';
      Font.Size := 12;

      Top := 110;
      Left := 60;
    end;

    // Advanced Dialog

    if Advanced then
    begin
      Height := Height + 100;

      //Create Labels
      with TLabel.Create(UI) do begin
        Parent := UI;

        Caption := 'R             G             B';

        Font.Name := 'Segoe UI';
        Font.Size := 12;

        Top := 235;
        Left := 20;
      end;
      with TLabel.Create(UI) do begin
        Parent := UI;

        Caption := 'HEX';

        Font.Name := 'Segoe UI';
        Font.Size := 12;

        Top := 235;
        Left := 220;
      end;
      with TLabel.Create(UI) do begin
        Parent := UI;

        Caption := 'Decimal';

        Font.Name := 'Segoe UI';
        Font.Size := 12;

        Top := 235;
        Left := 340;
      end;

      //Create Boxes
      CR := TEdit.Create(UI);
      with CR do begin
        Parent := UI;

        Left := 20;
        Top := 260;

        Width := 40;
        Height := 50;

        Font.Size := 12;

        Text := '0';

        TextHint := 'R';

        NumbersOnly := true;
        MaxLength := 3;

        OnExit := TextOnExit;
        OnKeyUp := EnterOnRGB;
      end;
      CG := TEdit.Create(UI);
      with CG do begin
        Parent := UI;

        Left := 80;
        Top := 260;

        Width := 40;
        Height := 50;

        Font.Size := 12;

        Text := '0';

        TextHint := 'G';

        NumbersOnly := true;
        MaxLength := 3;

        OnExit := TextOnExit;
        OnKeyUp := EnterOnRGB;
      end;
      CB := TEdit.Create(UI);
      with CB do begin
        Parent := UI;

        Left := 140;
        Top := 260;

        Width := 40;
        Height := 50;

        Font.Size := 12;

        Text := '0';

        TextHint := 'B';

        NumbersOnly := true;
        MaxLength := 3;

        OnExit := TextOnExit;
        OnKeyUp := EnterOnRGB;
      end;
      CHEX := TEdit.Create(UI);
      with CHEX do begin
        Parent := UI;

        Left := 220;
        Top := 260;

        Width := 80;
        Height := 50;

        Font.Size := 12;

        Text := '0';

        TextHint := 'HEX';

        OnExit := TextOnExit;
        OnKeyUp := EnterOnHEX;
      end;
      CDec := TEdit.Create(UI);
      with CDec do begin
        Parent := UI;

        Left := 340;
        Top := 260;

        Width := 80;
        Height := 50;

        Font.Size := 12;

        Text := '0';

        TextHint := 'Decimal';

        NumbersOnly := true;

        OnExit := TextOnExit;
        OnKeyUp := EnterOnDec;
      end;
    end;

    // Create Buttons
    with CButton.Create(UI) do begin
      Parent := UI;

      Text := 'Ok';
      ButtonIcon := cicYes;
      Top := Ui.Height - Height - 40;
      Left := Ui.Width - Width - 10;

      Default := true;
      Cancel := false;

      //TrueTransparency := false;

      ModalResult := mrOk;
    end;

    with CButton.Create(UI) do begin
      Parent := UI;

      Text := 'Cancel';
      ButtonIcon := cicNo;
      Top := Ui.Height - Height - 40;
      Left := Ui.Width - Width * 2 - 20;

      Default := false;
      Cancel := true;

      //TrueTransparency := false;

      ModalResult := mrClose;
    end;

    with TLabel.Create(UI) do begin
      Parent := UI;

      Caption := 'Brightness';

      Font.Name := 'Segoe UI';
      Font.Size := 12;

      Top := 60;
      Left := 200;
    end;

    CLbr := CColorBright.Create(UI);
    with CLbr do begin
      Parent := UI;

      Left := 200;
      Top := 90;

      Width := 250;
      Height := 20;

      PureColor := FColor;

      ChangeItemColor := ChangeIColor;
    end;
    CLbr.Invalidate;

    with TLabel.Create(UI) do begin
      Parent := UI;

      Caption := 'Preview && History';

      Font.Name := 'Segoe UI';
      Font.Size := 12;

      Top := 140;
      Left := 200;
    end;

    CBx := CColorBox.Create(UI);
    with CBx do begin
      Parent := UI;

      Top := 170;
      Left := 200;

      Transparent := False;

      ItemColor := FColor;

      PenThick := 3;

      Width := 40;
      Height := 40;
    end;

    with CColorBox.Create(UI) do begin
      Parent := UI;

      Top := 175;
      Left := 265;

      Transparent := False;

      ItemColor := FCHistory[1];
      OnClick := ClickHistory;
      Tag := 1;

      PenRound := 6;
      PenThick := 3;

      Width := 30;
      Height := 30;
    end;

    with CColorBox.Create(UI) do begin
      Parent := UI;

      Top := 175;
      Left := 300;

      Transparent := False;

      ItemColor := FCHistory[2];
      OnClick := ClickHistory;
      Tag := 2;

      PenRound := 6;
      PenThick := 3;

      Width := 30;
      Height := 30;
    end;

    with CColorBox.Create(UI) do begin
      Parent := UI;

      Top := 175;
      Left := 335;

      Transparent := False;

      ItemColor := FCHistory[3];
      OnClick := ClickHistory;
      Tag := 3;

      PenRound := 6;
      PenThick := 3;

      Width := 30;
      Height := 30;
    end;

    with CColorBox.Create(UI) do begin
      Parent := UI;

      Top := 175;
      Left := 370;

      Transparent := False;

      ItemColor := FCHistory[4];
      OnClick := ClickHistory;
      Tag := 4;

      PenRound := 6;
      PenThick := 3;

      Width := 30;
      Height := 30;
    end;

    with CColorBox.Create(UI) do begin
      Parent := UI;

      Top := 175;
      Left := 405;

      Transparent := False;

      ItemColor := FCHistory[5];
      OnClick := ClickHistory;
      Tag := 5;

      PenRound := 6;
      PenThick := 3;

      Width := 30;
      Height := 30;
    end;

    clwh := CColorWheel.Create(UI);
    with clwh do begin
      Parent := UI;

      Width := 150;
      Height := 150;

      Transparent := False;

      Left := 10;
      Top := 50;

      ColorBright := CLbr;

      Color := FColor;
    end;
    clwh.Invalidate;


    // Final Prep
    noact := 0;
    ChangeIColor(CLbr, CLbr.PureColor, 0, 0);

    // Finish Dialog
    if ShowModal = mrOk then
    begin
      FColor := CLbr.Color;
      AddNewColorToHistory(FColor);
      Result := true;
    end else Result := false;
  end;
end;

function CColorDialog.GetColor(Default: TColor): TColor;
begin
  FColor := ColorToRGB(Default);

  if Execute then
    Result := FColor
  else
    Result := FColor;
end;

procedure CColorDialog.ModifyColor(var objectcolor: TColor);
begin
  FColor := ColorToRGB(objectcolor);

  if Execute then
    objectcolor := FColor
  else
    objectcolor := FColor;
end;

procedure CColorDialog.TextOnExit(Sender: TObject);
begin
  noact := 0;
end;

end.

