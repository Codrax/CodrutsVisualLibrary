{***********************************************************}
{                 Codruts ByteUtils Utilities               }
{                                                           }
{                        version 0.2                        }
{                           ALPHA                           }
{                                                           }
{                                                           }
{                                                           }
{                                                           }
{                                                           }
{                   -- WORK IN PROGRESS --                  }
{***********************************************************}

unit Cod.ByteUtils;

interface
  uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, IOUTils,
  Cod.Types, Cod.StringUtils;

  function GetFileBytes(FileName: string): TArray<Byte>;
  function GetFileBytesString(FileName: string; FirstCount: integer = -1): TArray<string>;

  function ReadFileSignature(FileName: string): TFileType;

implementation

function GetFileBytes(FileName: string): TArray<Byte>;
begin
  // Get File
  Result := TFile.ReadAllBytes(FileName);
end;

function GetFileBytesString(FileName: string; FirstCount: integer): TArray<string>;
var
  Bytes: TBytes;
  I, Total: Integer;
begin
  // Get File
  Bytes := TFile.ReadAllBytes(FileName);
  Total := Length( Bytes );

  // Total Items
  if (FirstCount = -1) or (FirstCount > Total) then
    FirstCount := Total;

  // Size
  SetLength( Result, FirstCount );

  // Convert
  for I := 0 to FirstCount - 1 do
    Result[I] := DecToHex( Bytes[I] );
end;

function ReadFileSignature(FileName: string): TFileType;
const
  MAX_READ_BUFF = 16;

  FTYP = '66 74 79 70';

  BMP_SIGN: TArray<string> = ['42 4D'];
  PNG_SIGN: TArray<string> = ['89 50 4E 47 0D 0A 1A 0A'];
  GIF_SIGN: TArray<string> = ['47 49 46'];
  JPEG_SIGN: TArray<string> = ['FF D8 FF', '49 46 00 01'];
  HEIF_SIGN: TArray<string> = [FTYP + '68 65 69 63'];
  TIFF_SIGN: TArray<string> = ['49 49 2A 00', '4D 4D 00 2A'];

  MP3_SIGN: TArray<string> = ['49 44 33', 'FF FB', 'FF F3', 'FF F2'];
  MP4_SIGN: TArray<string> = [FTYP + '69 73 6F 6D'];
  FLAC_SIGN: TArray<string> = ['66 4C 61 43'];
  MDI_SIGN: TArray<string> = ['4D 54 68 64'];
  OGG_SIGN: TArray<string> = ['4F 67 67 53'];
  SND_SIGN: TArray<string> = ['2E 73 6E 64'];
  M3U8_SIGN: TArray<string> = ['23 45 58 54 4D 33 55'];

  EXE_SIGN: TArray<string> = ['4D 5A'];
  MSI_SIGN: TArray<string> = ['D0 CF 11 E0 A1 B1 1A E1'];

  ZIP_SIGN: TArray<string> = ['50 4B 03 04', '50 4B 05 06', '50 4B 07 08'];
  GZIP_SIGN: TArray<string> = ['1F 8B'];
  ZIP7_SIGN: TArray<string> = ['37 7A BC AF 27 1C'];
  CABINET_SIGN: TArray<string> = ['4D 53 43 46'];
  TAR_SIGN: TArray<string> = ['75 73 74 61 72 00 30 30', '75 73 74 61 72 20 20 00'];
  RAR_SIGN: TArray<string> = ['52 61 72 21 1A 07 00', '52 61 72 21 1A 07 01 00'];
  LZIP_SIGN: TArray<string> = ['4C 5A 49 50'];

  ISO_SIGN: TArray<string> = ['43 44 30 30 31', '49 73 5A 21'];

  PDF_SIGN: TArray<string> = ['25 50 44 46 2D'];

  HLP_SIGN: TArray<string> = ['3F 5F'];

  CHM_SIGN: TArray<string> = ['49 54 53 46 03 00 00 00'];
var
  HexArray: TArray<string>;
  HEX: string;
  I: Integer;

function HasSignature(HEX: string; ValidSign: TArray<string>): boolean;
var
  I: integer;
begin
  Result := false;
  for I := 0 to High(ValidSign) do
    begin
      ValidSign[I] := ValidSign[I].Replace(' ', '');

      if StrFirst( HEX, Length(ValidSign[I]) ) = ValidSign[I] then
        Exit(True);
    end;
end;
begin
  Result := dftText;

  // Get File
  HexArray := GetFileBytesString( FileName, MAX_READ_BUFF );

  HEX := '';
  for I := 0 to High(HexArray) do
    HEX := HEX + HexArray[I];

  SetLength(HexArray, 0);

  // Invalid
  if HEX = '' then
    Exit;

  // All Types Listed (not great)

  (* Picture Types *)
  if HasSignature(HEX, BMP_SIGN) then
    Exit( dftBMP );

  if HasSignature(HEX, PNG_SIGN) then
    Exit( dftPNG );

  if HasSignature(HEX, JPEG_SIGN) then
    Exit( dftJPEG );

  if HasSignature(HEX, GIF_SIGN) then
    Exit( dftGIF );

  if HasSignature(StrRemove(HEX, 1, 8), HEIF_SIGN) then
    Exit( dftHEIC );

  if HasSignature(HEX, TIFF_SIGN) then
    Exit( dftTIFF );

  (* Video/Audio Media *)
  if HasSignature(HEX, MP3_SIGN) then
    Exit( dftMP3 );

  if HasSignature(StrRemove(HEX, 1, 8), MP4_SIGN) then
    Exit( dftMP4 );

  if HasSignature(HEX, FLAC_SIGN) then
    Exit( dftFlac );

  if HasSignature(HEX, MDI_SIGN) then
    Exit( dftMDI );

  if HasSignature(HEX, OGG_SIGN) then
    Exit( dftOGG );

  if HasSignature(HEX, SND_SIGN) then
    Exit( dftSND );

  if HasSignature(HEX, M3U8_SIGN) then
    Exit( dftM3U8 );

  (* Executable *)
  if HasSignature(HEX, EXE_SIGN) then
    Exit( dftEXE );

  if HasSignature(HEX, MSI_SIGN) then
    Exit( dftMSI );

  (* Zip *)
  if HasSignature(HEX, ZIP_SIGN) then
    Exit( dftZip );

  if HasSignature(HEX, GZIP_SIGN) then
    Exit( dftGZip );

  if HasSignature(HEX, ZIP7_SIGN) then
    Exit( dft7Zip );

  if HasSignature(HEX, CABINET_SIGN) then
    Exit( dftCabinet );

  if HasSignature(HEX, TAR_SIGN) then
    Exit( dftTAR );

  if HasSignature(HEX, RAR_SIGN) then
    Exit( dftRAR );

  if HasSignature(HEX, LZIP_SIGN) then
    Exit( dftLZIP );

  (* ISO *)
  if HasSignature(HEX, ISO_SIGN) then
    Exit( dftISO );

  (* PDF *)
  if HasSignature(HEX, PDF_SIGN) then
    Exit( dftPDF );

  (* Help File *)
  if HasSignature(HEX, HLP_SIGN) then
    Exit( dftHLP );

  if HasSignature(HEX, CHM_SIGN) then
    Exit( dftCHM );
end;

end.