unit Cod.Dialogs.PrintDlg;

interface

uses
  Winapi.Windows, Winapi.Messages, SysUtils, Classes, Graphics, CommDlg,
  Cod.Graphics, Vcl.Dialogs, Vcl.Controls, Vcl.Forms;

  type
    CPrintDialog = class(TComponent)
    private
      FModal: boolean;
      FCollate: boolean;
      FCopies,
      FFromPage,
      FToPage,
      FMaxPage,
      FMinPage: integer;
      FPrintRange: TPrintRange;
      FPrintToFile: boolean;
      FDocumentName: string;
      FShowPrintToFile: boolean;
      FPageSetup: boolean;

      FPageSize: TRect;
      ADocInfo: TDocInfo;

      function GetCanvas: TCanvas;

    published
      property Collate: boolean read FCollate write FCollate default false;
      property Copies: integer read FCopies write FCopies default 0;
      property FromPage: integer read FFromPage write FFromPage default 0;
      property ToPage: integer read FToPage write FToPage default 0;
      property MaxPage: integer read FMaxPage write FMaxPage default 0;
      property MinPage: integer read FMinPage write FMinPage default 0;
      property PrintRange: TPrintRange read FPrintRange write FPrintRange default prAllPages;
      property PrintToFile: boolean read FPrintToFile write FPrintToFile default false;
      property ShowPrintToFile: boolean read FShowPrintToFile write FShowPrintToFile default true;
      property DocumentName: string read FDocumentName write FDocumentName;
      property Modal: boolean read FModal write FModal default true;
      property PageSetup: boolean read FPageSetup write FPageSetup default false;

      property Canvas: TCanvas read GetCanvas;

    public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;

      // Dialog
      function Execute: boolean;
      procedure FreeDialogHDC;

      // Page Info
      function PageSize: TRect;
      procedure StartDocument;
      procedure EndDocument;
      procedure NewPage;
      procedure ClosePage;

      var
      DialogHDC: HDC;
  end;

implementation

constructor CPrintDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  DocumentName := 'Print Document';

  FModal := true;
  FShowPrintToFile := true;
end;

destructor CPrintDialog.Destroy;
begin
  inherited;
end;

procedure CPrintDialog.EndDocument;
begin
  EndDoc( DialogHDC );
end;

procedure CPrintDialog.ClosePage;
begin
  EndPage( DialogHDC );
end;

function CPrintDialog.Execute: boolean;
var
  PrintDlgRec: TPrintDlgW;
begin
  Result := false;

  FillChar(ADocInfo, SizeOf(DocInfo), 0);
  with ADocInfo do
  begin
    cbSize := SizeOf(DocInfo);
    lpszDocName := PChar(DocumentName);
    lpszOutput := nil;
    lpszDatatype := nil;
    fwType := 0;
  end;
  FillChar(PrintDlgRec, SizeOf(PrintDlgRec), 0);

  with PrintDlgRec do
    begin
      nCopies := Copies;
      nFromPage := FromPage;
      nToPage := ToPage;
      nMaxPage := MaxPage;
      nMinPage := MinPage;

      // Print Range
      case PrintRange of
        prAllPages: Flags := Flags or PD_ALLPAGES;
        prSelection: Flags := Flags or PD_SELECTION;
        prPageNums: Flags := Flags or PD_PAGENUMS;
      end;

      // Options
      if Collate then
        Flags := Flags or PD_COLLATE;

      if PrintToFile then
        Flags := Flags or PD_PRINTTOFILE;

      // Configure Dialog
      if not FShowPrintToFile then
        Flags := Flags or PD_HIDEPRINTTOFILE;

      if FPageSetup then
        Flags := Flags or PD_PRINTSETUP;

      // Config
      lStructSize := SizeOf(PrintDlgRec);
      if Modal then
        hwndOwner := Application.MainForm.Handle
      else
        hwndOwner := Application.Handle;
      Flags := Flags or PD_RETURNDC;
    end;

  if PrintDlgW(PrintDlgRec) then
    begin
      Result := true;

      DialogHDC := PrintDlgRec.hDC;

      // Use the GetDeviceCaps function to retrieve information about the printer
      GetDeviceCaps(DialogHDC, TECHNOLOGY);
      GetDeviceCaps(DialogHDC, DC_COLORDEVICE);
      GetDeviceCaps(DialogHDC, BITSPIXEL);
      GetDeviceCaps(DialogHDC, PLANES);
      GetDeviceCaps(DialogHDC, NUMCOLORS);
      GetDeviceCaps(DialogHDC, LOGPIXELSX);
      GetDeviceCaps(DialogHDC, LOGPIXELSY);

      // Get Size
      FPageSize := Rect(0, 0, GetDeviceCaps(DialogHDC, PHYSICALWIDTH),
                        GetDeviceCaps(DialogHDC, PHYSICALHEIGHT));

      // Get Data
      with PrintDlgRec do
        begin
          // Pages
          Copies := nCopies;
          FromPage := nFromPage;
          ToPage := nToPage;
          MaxPage := nMaxPage;
          MinPage := nMinPage;

          // Flags
          if (Flags and PD_PAGENUMS) <> 0 then
            PrintRange := prPageNums
              else
                if (Flags and PD_SELECTION) <> 0 then
                  PrintRange := prSelection
                    else
                      PrintRange := prAllPages;

          // All Pages
          if PrintRange = prAllPages then
            begin
              FromPage := MinPage;
              ToPage := MaxPage;
            end;
        end;
    end;
end;


procedure CPrintDialog.FreeDialogHDC;
begin
  DeleteDC(Self.DialogHDC);
end;

function CPrintDialog.GetCanvas: TCanvas;
begin
  Result := TCanvas.Create;
  Result.Handle := DialogHDC;
end;

procedure CPrintDialog.NewPage;
begin
  StartPage( DialogHDC );
end;

function CPrintDialog.PageSize: TRect;
begin
  Result := FPageSize;
end;

procedure CPrintDialog.StartDocument;
begin
  StartDoc( DialogHDC, ADocInfo);
end;

end.
