unit Cod.Components.Register;

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
    Cod.Visual.Scrollbar,

    // Dialogs
    Cod.Dialogs.ColorDialog,
    Cod.Dialogs.IconPicker,
    Cod.Dialogs.PrintDlg,

    // Non-Visual Components
    Cod.Component.HotKey;

  procedure Register;

const
  CATEGORY_VISUAL = 'Codrut Components';
  CATEGORY_TOOL = 'Cod Utils';

implementation

procedure Register;
begin
  // UI
  RegisterComponents( CATEGORY_VISUAL, [CButton, CGlassBlur, CColorBox,
      CColorBright, CColorWheel, CPanel, CMinimisePanel, CCheckBox, CChart,
      CLabel, CStandardIcon, CImage, CStarRate, CSplashScreen, CProgress,
      CSlider, CLoadAnim, CScrollbar] );

  // Components
  RegisterComponents( CATEGORY_TOOL, [CColorDialog, CIconPicker, CHotKey,
      CPrintDialog, CPrintDialog{, TAudioBox}] );
end;

end.
