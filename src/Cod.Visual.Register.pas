unit Cod.Visual.Register;

interface
  uses
    Classes,

    // Components
    Cod.Visual.GlassBlur,
    Cod.Visual.ColorBox,
    Cod.Visual.ColorBright,
    Cod.Visual.ColorWheel,
    Cod.Visual.Panels,
    Cod.Visual.CPSharedLib,
    Cod.Visual.CheckBox,
    Cod.Visual.Chart,
    Cod.Visual.Labels,
    Cod.Visual.StandardIcons,
    Cod.Visual.Image,
    Cod.Visual.Button,
    Cod.Visual.StarRate,
    Cod.Visual.SplashScreen,
    Cod.Visual.Progress,
    Cod.Visual.Slider,
    Cod.Visual.LoadIco,

    // Non-Visual Components
    Cod.ColorDialog,
    Cod.IconPicker,
    Cod.HotKey,
    Cod.PrintDlg;

  procedure Register;

const
  CATEGORY_VISUAL = 'Codrut Components';
  CATEGORY_TOOL = 'Cod Utils';

implementation

procedure Register;
begin
  RegisterComponents( CATEGORY_VISUAL, [CButton, CGlassBlur, CColorBox,
      CColorBright, CColorWheel, CPanel, CMinimisePanel, CCheckBox, CChart,
      CLabel, CStandardIcon, CImage, CStarRate, CSplashScreen, CProgress,
      CSlider, CLoadAnim] );

  RegisterComponents( CATEGORY_TOOL, [CColorDialog, CIconPicker, CHotKey,
      CPrintDialog, CPrintDialog{, TAudioBox}] );
end;

end.
