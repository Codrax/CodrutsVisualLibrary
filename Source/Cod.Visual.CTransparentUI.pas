unit Cod.Visual.CTransparentUI;

interface

uses
  SysUtils,
  Classes,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ExtCtrls,
  Cod.Components;

type
  CTestTr = class(TCustomTransparentControl)
      constructor Create(AOwner : TComponent); override;
      destructor Destroy; override;
    private

    protected
      procedure Paint; override;
    published
      property OnMouseEnter;
      property OnMouseLeave;
      property OnMouseDown;
      property OnMouseUp;
      property OnMouseMove;
      property OnClick;

      property Align;
      property Anchors;
      property Cursor;
      property Visible;
      property Enabled;
      property Constraints;
      property DoubleBuffered;
  end;

implementation

{ CProgress }

constructor CTestTr.Create(AOwner: TComponent);
begin
  inherited;
  interceptmouse:=True;

  Width := 100;
  Height := 100;
end;

destructor CTestTr.Destroy;
begin

  inherited;
end;


procedure CTestTr.Paint;
begin
  inherited;
  with canvas do begin
    TextOut(10,10,'Hello!');


  end;

end;

end.
