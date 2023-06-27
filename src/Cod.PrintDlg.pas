unit Cod.PrintDlg;

interface

uses
  Winapi.Windows, Winapi.Messages, SysUtils, Classes, Graphics, CommDlg,
  Cod.Graphics, Vcl.Dialogs, Vcl.Controls, Vcl.Forms;

  type
    CPrintDialogItems = (poPageNums, poSelection, poWarning, poHelp, poDisablePrintToFile);
    CPrintDialogOptions = set of CPrintDialogItems;

    CPrintDialog = class(TComponent)
    public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;

      // Dialog
      function Execute: boolean;
      procedure FreeDialogHDC;

      function GetCanvas: TCanvas;


      // Page Info
      function PageSize: TRect;
      procedure StartDocument;
      procedure EndDocument;
      procedure NewPage;
      procedure ClosePage;

      var
      DialogHDC: HDC;

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
      FOptions: CPrintDialogOptions;

      FPageSize: TRect;
      ADocInfo: TDocInfo;

    published
      property Collate: boolean read FCollate write FCollate default false;
      property Copies: integer read FCopies write FCopies default 0;
      property FromPage: integer read FFromPage write FFromPage default 0;
      property ToPage: integer read FToPage write FToPage default 0;
      property MaxPage: integer read FMaxPage write FMaxPage default 0;
      property MinPage: integer read FMinPage write FMinPage default 0;
      property PrintRange: TPrintRange read FPrintRange write FPrintRange default prAllPages;
      property PrintToFile: boolean read FPrintToFile write FPrintToFile default false;
      property DocumentName: string read FDocumentName write FDocumentName;
      property Options: CPrintDialogOptions read FOptions write FOptions default [];
      property Modal: boolean read FModal write FModal;

      property Canvas: TCanvas read GetCanvas;
  end;

implementation

constructor CPrintDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  DocumentName := 'Print Document';

  FOptions := [];
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
    nToPage := Self.ToPage;
    nMaxPage := MaxPage;
    nMinPage := MinPage;

    // Print Range
    case PrintRange of
      prAllPages: Flags := Flags or PD_ALLPAGES;
      prSelection: Flags := Flags or PD_SELECTION;
      prPageNums: Flags := Flags or PD_PAGENUMS;
    end;

    if Collate then
      Flags := Flags or PD_COLLATE;

    if PrintToFile then
      Flags := Flags or PD_PRINTTOFILE;

    // Options
    if (poDisablePrintToFile in Options) then
      Flags := Flags or PD_DISABLEPRINTTOFILE;
    if (poPageNums in Options) then
      Flags := Flags or PD_PAGENUMS;
    if (poSelection in Options) then
      Flags := Flags or PD_SELECTION;
    if not (poWarning in Options) then
      Flags := Flags or PD_NOWARNING;


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
    end;
  {begin
    hhDC := PrintDlgRec.hDC;
    hDevMode := PrintDlgRec.hDevMode;
    if hhDC <> 0 then
    begin
      // Use the DeleteDC function to delete the device context
      DeleteDC(hhDC);
    end;
    if hDevMode <> 0 then
    begin
      // Use the GlobalFree function to free the memory allocated for the DEVMODE structure
      GlobalFree(hDevMode);
    end;
  end;                     }
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
