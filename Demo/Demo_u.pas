unit Demo_u;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.GIFImg, Vcl.Imaging.pngimage, Cod.Dialogs,
  Cod.Visual.GlassBlur, Cod.Visual.Panels, Cod.Visual.Image, Cod.Visual.Slider,
  Cod.Visual.SplashScreen, Cod.Visual.StarRate, Cod.Visual.CheckBox,
  Cod.Visual.ColorWheel, Cod.Visual.ColorBright, Cod.Visual.ColorBox,
  Cod.Visual.Progress, Cod.Visual.StandardIcons, Cod.Visual.Chart,
  Cod.Visual.Button, Cod.Dialogs.ColorDialog;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Timer1: TTimer;
    nxpg: CButton;
    pvpg: CButton;
    Label7: TLabel;
    pg2: TPanel;
    Label8: TLabel;
    CColorBox1: CColorBox;
    CColorBright1: CColorBright;
    CColorWheel1: CColorWheel;
    CCheckBox1: CCheckBox;
    CCheckBox2: CCheckBox;
    CCheckBox3: CCheckBox;
    CCheckBox4: CCheckBox;
    CCheckBox5: CCheckBox;
    CCheckBox6: CCheckBox;
    Label6: TLabel;
    CStarRate1: CStarRate;
    Label9: TLabel;
    CStarRate2: CStarRate;
    CStarRate3: CStarRate;
    Label10: TLabel;
    CSplashScreen1: CSplashScreen;
    CSlider1: CSlider;
    CSlider2: CSlider;
    CSlider3: CSlider;
    CSlider4: CSlider;
    pg1: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    CButton1: CButton;
    CButton2: CButton;
    CButton3: CButton;
    CButton4: CButton;
    CButton5: CButton;
    CButton6: CButton;
    CButton7: CButton;
    CChart1: CChart;
    CChart2: CChart;
    CChart3: CChart;
    CChart4: CChart;
    CChart5: CChart;
    CStandardIcon1: CStandardIcon;
    CStandardIcon2: CStandardIcon;
    CStandardIcon3: CStandardIcon;
    CStandardIcon4: CStandardIcon;
    CStandardIcon5: CStandardIcon;
    CStandardIcon6: CStandardIcon;
    CButton8: CButton;
    CButton9: CButton;
    CButton10: CButton;
    CButton11: CButton;
    CButton13: CButton;
    CButton14: CButton;
    CButton15: CButton;
    CProgress1: CProgress;
    CProgress2: CProgress;
    CProgress3: CProgress;
    CProgress4: CProgress;
    pg3: TPanel;
    Label11: TLabel;
    CPanel1: CPanel;
    CPanel2: CPanel;
    CPanel3: CPanel;
    CPanel4: CPanel;
    Label12: TLabel;
    CMinimisePanel1: CMinimisePanel;
    CMinimisePanel2: CMinimisePanel;
    CMinimisePanel3: CMinimisePanel;
    CButton12: CButton;
    CButton16: CButton;
    CButton17: CButton;
    Label13: TLabel;
    pg4: TPanel;
    Label14: TLabel;
    CButton18: CButton;
    Edit1: TEdit;
    Edit2: TEdit;
    ComboBox1: TComboBox;
    CColorBox2: CColorBox;
    CheckBox1: TCheckBox;
    CColorBox3: CColorBox;
    CColorDialog1: CColorDialog;
    ComboBox2: TComboBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    aaaa: TLabel;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    Label15: TLabel;
    CButton19: CButton;
    CButton20: CButton;
    CheckBox9: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    CColorDialog2: CColorDialog;
    Label16: TLabel;
    CButton21: CButton;
    Memo1: TMemo;
    CButton22: CButton;
    CButton23: CButton;
    pg5: TPanel;
    CGlassBlur: TLabel;
    CGlassBlur1: CGlassBlur;
    CGlassBlur2: CGlassBlur;
    CGlassBlur3: CGlassBlur;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label26: TLabel;
    CImage11: CImage;
    CImage6: CImage;
    Label25: TLabel;
    Label24: TLabel;
    CImage10: CImage;
    Label23: TLabel;
    CImage9: CImage;
    Label22: TLabel;
    CImage8: CImage;
    Label21: TLabel;
    CImage7: CImage;
    procedure CProgress1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CProgress1MouseLeave(Sender: TObject);
    procedure CProgress1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure CProgress1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure CColorBright1ChangeItemColor(Sender: CColorBright; Color: TColor;
      X, Y: Integer);
    procedure nxpgClick(Sender: TObject);
    procedure pvpgClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CButton18Click(Sender: TObject);
    procedure GetClr(Sender: TObject);
    procedure CButton19Click(Sender: TObject);
    procedure CButton20Click(Sender: TObject);
    procedure CButton21Click(Sender: TObject);
    procedure CButton22Click(Sender: TObject);
    procedure CButton23Click(Sender: TObject);
  private
    { Private declarations }
    procedure GoToPage(pg: integer);

    procedure FormMove(var Msg: TMsg); message WM_MOVE;
  public
    { Public declarations }
  end;

const
  pages = 5;

var
  Form1: TForm1;
  progmsdown: boolean;
  page: integer = 1;

implementation

{$R *.dfm}

procedure TForm1.nxpgClick(Sender: TObject);
begin
  GoToPage(page + 1);
end;

procedure TForm1.pvpgClick(Sender: TObject);
begin
  GoToPage(page - 1);
end;

procedure TForm1.CButton18Click(Sender: TObject);
var
  a: TMsgDlgButtons;
  BTCOLOR: integer;
begin
  a := [];
  if CheckBOx2.Checked then
    a := a + [TMsgDlgBtn.mbOK];
  if CheckBOx3.Checked then
    a := a + [TMsgDlgBtn.mbYes];
  if CheckBOx4.Checked then
    a := a + [TMsgDlgBtn.mbNo];
  if CheckBOx5.Checked then
    a := a + [TMsgDlgBtn.mbCancel];

  if CheckBox7.Checked then
    BTCOLOR := -1
  else
    BTCOLOR := CColorBox3.ItemColor;

  CodDialog(Edit1.Text, Edit2.Text, CMessageType(ComboBox1.ItemIndex),
            a,CButtonPreset(ComboBox2.ItemIndex), CColorBox2.ItemColor,
            CheckBOx1.Checked, BTCOLOR, CheckBox6.Checked );
end;

procedure TForm1.GetClr(Sender: TObject);
begin
  CColorBox(Sender).ItemColor := CColorDialog1.GetColor(CColorBox(Sender).ItemColor);
end;

procedure TForm1.CButton19Click(Sender: TObject);
var
  BTCOLOR: integer;
begin
  if CheckBox7.Checked then
    BTCOLOR := -1
  else
    BTCOLOR := CColorBox3.ItemColor;

    CodMessage(Edit1.Text, Edit2.Text, CButtonPreset(ComboBox2.ItemIndex), CColorBox2.ItemColor,
            CheckBOx1.Checked, BTCOLOR, CheckBox6.Checked );
end;

procedure TForm1.CButton20Click(Sender: TObject);
var
  passchar: char;
  BTCOLOR: integer;
begin
  passchar := #0;

  if CheckBox11.Checked then
    passchar := '*';

  if CheckBox7.Checked then
    BTCOLOR := -1
  else
    BTCOLOR := CColorBox3.ItemColor;

    CodInput(Edit1.Text, Edit2.Text, 'pre data', CheckBox10.Checked,
             CheckBox9.Checked, passchar, CButtonPreset(ComboBox2.ItemIndex),
             CColorBox2.ItemColor, CheckBOx1.Checked, BTCOLOR,
             CheckBox6.Checked );
end;

procedure TForm1.CButton21Click(Sender: TObject);
begin
  CButton(Sender).Colors.Leave := CColorDialog1.GetColor(CButton(Sender).Colors.Leave);
end;

procedure TForm1.CButton22Click(Sender: TObject);
var
  BTCOLOR: integer;
begin
  if CheckBox7.Checked then
    BTCOLOR := -1
  else
    BTCOLOR := CColorBox3.ItemColor;

    CodDropDown(Edit1.Text, Edit2.Text, TStringList(Memo1.Lines), CheckBox10.Checked,
            CButtonPreset(ComboBox2.ItemIndex), CColorBox2.ItemColor,
            CheckBOx1.Checked, BTCOLOR, CheckBox6.Checked );
end;

procedure TForm1.CButton23Click(Sender: TObject);
var
  BTCOLOR: integer;
begin
  if CheckBox7.Checked then
    BTCOLOR := -1
  else
    BTCOLOR := CColorBox3.ItemColor;

    CodRadioDialog(Edit1.Text, Edit2.Text, TStringList(Memo1.Lines), CheckBox10.Checked,
            CButtonPreset(ComboBox2.ItemIndex), CColorBox2.ItemColor,
            CheckBOx1.Checked, BTCOLOR, CheckBox6.Checked );
end;

procedure TForm1.CColorBright1ChangeItemColor(Sender: CColorBright;
  Color: TColor; X, Y: Integer);
begin
  try
    CColorBox1.ItemColor := CColorBright1.Color;
  except

  end;
end;

procedure TForm1.CProgress1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  progmsdown := true;
  if progmsdown then
    CProgress1.Position := trunc(x/CProgress1.Width * 100)
end;

procedure TForm1.CProgress1MouseLeave(Sender: TObject);
begin
  progmsdown := false;
end;

procedure TForm1.CProgress1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if progmsdown then
    CProgress1.Position := trunc(x/CProgress1.Width * 100)
end;

procedure TForm1.CProgress1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    progmsdown := false;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  GoToPage(1);
end;

procedure TForm1.FormMove(var Msg: TMsg);
begin
  // Manual Glass Blur Redraw
  if Self.Visible and pg5.Visible then
    begin
      CGlassBlur1.SyncroniseImage;
      CGlassBlur2.SyncroniseImage;
      CGlassBlur3.SyncroniseImage;
    end;
end;

procedure TForm1.GoToPage(pg: integer);
var
  pan: TPanel;
begin
  if pg > pages then pg := pages;

  page := pg;

  case pg of
    1: pan := pg1;
    2: pan := pg2;
    3: pan := pg3;
    4: pan := pg4;
    5: pan := pg5;
    else Exit;
  end;

  pan.BringToFront;
  pan.Invalidate;

  if pg = 1 then pvpg.Enabled := false else pvpg.Enabled := true;
  if pg = pages then nxpg.Enabled := false else nxpg.Enabled := true;

  Label7.Caption := 'Page ' + pg.ToString + ' of ' + pages.ToString;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  CChart1.Position := Random(101);
end;

end.
