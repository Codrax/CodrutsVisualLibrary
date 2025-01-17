unit Cod.Visual.CPSharedLib;

interface
uses
  UITypes,
  Classes,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.Graphics,
  SysUtils,
  Vcl.Styles,
  Vcl.Themes,
  Types;

const
  nothemes: TArray<string> = ['Windows', 'Mountain_Mist'];

  function StrInArray(const Value : String;const ArrayOfString : Array of String) : Boolean;
  function GetFormColor(component: TControl): TColor;

implementation

function GetFormColor(component: TControl): TColor;
begin
  if StrInArray(TStyleManager.ActiveStyle.Name, nothemes) then begin
      try
        Result := GetParentForm(component).Color;
      except
        Result := TStyleManager.ActiveStyle.GetSystemColor(clBtnFace);
      end;
    end else
      Result := TStyleManager.ActiveStyle.GetSystemColor(clBtnFace);
end;

function StrInArray(const Value : String;const ArrayOfString : Array of String) : Boolean;
var
 Loop : String;
begin
  for Loop in ArrayOfString do
  begin
    if Value = Loop then
    begin
       Exit(true);
    end;
  end;
  result := false;
end;

end.
