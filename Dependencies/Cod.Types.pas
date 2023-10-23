{***********************************************************}
{                      Codrut Classes                       }
{                                                           }
{                        version 0.4                        }
{                           ALPHA                           }
{                                                           }
{                                                           }
{                                                           }
{                                                           }
{                                                           }
{                   -- WORK IN PROGRESS --                  }
{***********************************************************}

unit Cod.Types;

{$SCOPEDENUMS ON }

interface
  uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Variants, Vcl.Clipbrd, IOUtils, Math, Types, DateUtils;

  type
    // Cardinals
    TCorners = (TopLeft, TopRight, BottomLeft, BottomRight);

    TRelation = (Smaller, Equal, Bigger);

    TLayout = (Beginning, Center, Ending);

    TFileType = (Text, BMP, PNG, JPEG, GIF, HEIC, TIFF, MP3, MP4, Flac, MDI,
    OGG, SND, M3U8, EXE, MSI, Zip, GZip, Zip7, Cabinet, TAR, RAR, LZIP, ISO,
    PDF, HLP, CHM);

    // Graphic ans Canvas
    TRoundRect = record
      public
        Rect: TRect;

        RoundTL,
        RoundTR,
        RoundBL,
        RoundBR: integer;

        Corners: TCorners;

        function Left: integer;
        function Right: integer;
        function Top: integer;
        function Bottom: integer;
        function TopLeft: TPoint;
        function BottomRight: TPoint;
        function Height: integer;
        function Width: integer;

        procedure Offset(const DX, DY: Integer);

        procedure SetRoundness(Value: integer);
        function GetRoundness: integer;

        function RoundX: integer;
        function RoundY: integer;

        constructor Create(TopLeft, BottomRight: TPoint; Rnd: integer); overload;
        constructor Create(SRect: TRect; Rnd: integer); overload;
        constructor Create(Left, Top, Right, Bottom: integer; Rnd: integer); overload;
    end;

    TLine = record
      Point1: TPoint;
      Point2: TPoint;

      constructor Create(P1, P2: TPoint);

      procedure OffSet(const DX, DY: Integer);

      function Rect: TRect;
      function GetHeight: integer;
      function GetWidth: integer;

      function Center: TPoint;
    end;

    TLineF = record
      Point1: TPointF;
      Point2: TPointF;

      constructor Create(P1, P2: TPointF);

      procedure OffSet(const DX, DY: single);

      function Rect: TRectF;
      function GetHeight: single;
      function GetWidth: single;

      function Center: TPointF;
    end;

    T4PointPolygon = record
      Point: array[1..4] of TPoint;

      constructor Create(P1, P2, P3, P4: TPoint);

      function Center: TPoint;

      function Left: integer;
      function Right: integer;
      function Top: integer;
      function Bottom: integer;

      procedure Offset(X, Y: integer); overload;
      procedure Offset(By: TPoint); overload;
      procedure Rotate(Degrees: real);

      function ToRect: TRect;
    end;

    // Math & Array
    TIntegerList = class;

    TIntegerListSortCompare = function(List: TIntegerList; Index1, Index2: Integer): Integer;

    TIntegerList = class(TObject)
    private
      FList : TList;
      FDuplicates : TDuplicates;
      FSorted: Boolean;

      function GetItems(Index: Integer): Integer;
      procedure SetItems(Index: Integer; const Value: Integer);
      function GetCapacity: Integer;
      function GetCount: Integer;
      procedure SetCapacity(const Value: Integer);
      procedure SetCount(const Value: Integer);
      procedure SetSorted(const Value: Boolean);
      function GetHigh: Integer;

    protected
      procedure Sort; virtual;
      procedure QuickSort(L, R: Integer; SCompare: TIntegerListSortCompare);

    public
      constructor Create;
      destructor Destroy; override;

      function Add(Item: Integer) : Integer;
      procedure Insert(Index, Item: Integer);

      function First() : Integer;
      function Last() : Integer;

      function StringContents: string;
      procedure LoadFromString(AString: string; Separator: string = ',');

      procedure Clear;
      procedure Delete(Index: Integer);

      function IndexOf(const Value: integer): integer;
      function Find(aValue : Integer; var Index: Integer): Boolean; virtual;

      procedure Exchange(Index1, Index2: Integer);
      procedure Move(CurIndex, NewIndex: Integer);
      procedure Pack;

      property Capacity: Integer read GetCapacity write SetCapacity;
      property Count: Integer read GetCount write SetCount;
      property High: Integer read GetHigh;

      property Duplicates: TDuplicates read FDuplicates write FDuplicates;

      property Items[Index: Integer]: Integer read GetItems write SetItems; default;

      property Sorted : Boolean read FSorted write SetSorted;
    end;

  // Types
  function MakeRoundRect(SRect: TRect; Rnd: integer): TRoundRect; overload;
  function MakeRoundRect(SRect: TRect; RndX, RndY: integer): TRoundRect; overload;
  function MakeRoundRect(X1, Y1, X2, Y2: integer; Rnd: integer): TRoundRect; overload;

  function Line(Point1, Point2: TPoint): TLine; overload;
  function Line(X1, Y1, X2, Y2: integer): TLine; overload;

  function CompareItems(Primary, Secondary: string): TRelation; overload;
  function CompareItems(Primary, Secondary: integer): TRelation; overload;
  function CompareItems(Primary, Secondary: real): TRelation; overload;
  function CompareItems(Primary, Secondary: TDateTime): TRelation; overload;

  // Utilities
  function PointOnLine(X, Y, x1, y1, x2, y2, d: Integer): Boolean;

  { Rectangles }
  function GetValidRect(Point1, Point2: TPoint): TRect; overload;
  function GetValidRect(Points: TArray<TPoint>): TRect; overload;
  function GetValidRect(Rect: TRect): TRect; overload;
  procedure CenterRectInRect(var ARect: TRect; const ParentRect: TRect);
  procedure CenterRectAtPoint(var ARect: TRect; const APoint: TPoint);
  function PointInRect(Point: TPoint; Rect: TRect): boolean;
  procedure ContainRectInRect(var ARect: TRect; const ParentRect: TRect);

  { Points }
  function SetPositionAroundPoint(Point: TPoint; Center: TPoint; degree: real; customradius: real = -1): TPoint;
  function PointAroundCenter(Center: TPoint; degree: real; customradius: real = -1): TPoint;
  function RotatePointAroundPoint(APoint: TPoint; ACenter: TPoint; ARotateDegree: real; ACustomRadius: real = -1): TPoint;
  function PointAngle(APoint: TPoint; ACenter: TPoint; offset: integer = 0): integer;

  // Conversion Functions
  function StringToBoolean(str: string): Boolean;
  function BooleanToString(value: boolean): String;
  function BooleanToYesNo(value: boolean): String;
  function IconToBitmap(icon: TIcon): TBitMap;
  function IntToStrIncludePrefixZeros(Value: integer; NumbersCount: integer): string;

  function DecToHex(Dec: int64): string;
  function HexToDec(Hex: string): int64;

  { Arrays }
  function InArray(Value: integer; arrayitem: array of integer): integer; overload;
  function InArray(Value: string; arrayitem: array of string): integer; overload;
  procedure ShuffleArray(var arr: TArray<Integer>);
  procedure ArrayAdd(Data: string; var AArray: TArray<string>; CheckDuplicate: boolean = false);
  procedure ArrayRemove(Data: string; var AArray: TArray<string>; RemoveAll: boolean = true);

implementation


function MakeRoundRect(SRect: TRect; Rnd: integer): TRoundRect;
var
  rec: TRoundRect;
begin
  rec.Create(SRect, Rnd);
  Result := rec;
end;

function MakeRoundRect(SRect: TRect; RndX, RndY: integer): TRoundRect; overload;
var
  rec: TRoundRect;
begin
  rec.Create(SRect, (RndX + RndY) div 2);
  Result := rec;
end;

function MakeRoundRect(X1, Y1, X2, Y2: integer; Rnd: integer): TRoundRect;
var
  rec: TRoundRect;
begin
  rec.Create(Rect(X1, Y1, X2, Y2), Rnd);
  Result := rec;
end;

function Line(Point1, Point2: TPoint): TLine;
begin
  Result.Point1 := Point1;
  Result.Point2 := Point2;
end;

function Line(X1, Y1, X2, Y2: integer): TLine;
begin
  Result.Point1 := Point(X1, Y1);
  Result.Point2 := Point(X2, Y2);
end;

function CompareItems(Primary, Secondary: string): TRelation;
begin
  Result := TRelation.Smaller;

  if Primary > Secondary then
    Result := TRelation.Bigger
      else
        if Primary = Secondary then
          Result := TRelation.Equal;
end;

function CompareItems(Primary, Secondary: integer): TRelation; overload;
begin
  Result := TRelation.Smaller;

  if Primary > Secondary then
    Result := TRelation.Bigger
      else
        if Primary = Secondary then
          Result := TRelation.Equal;
end;

function CompareItems(Primary, Secondary: real): TRelation; overload;
begin
  Result := TRelation.Smaller;

  if Primary > Secondary then
    Result := TRelation.Bigger
      else
        if Primary = Secondary then
          Result := TRelation.Equal;
end;

function CompareItems(Primary, Secondary: TDateTime): TRelation; overload;
begin
  Result :=  TRelation(CompareDateTime(Primary, Secondary)+1);
end;

function PointOnLine(X, Y, x1, y1, x2, y2, d: Integer): Boolean;
var
  l, p: real;
begin
  p := sqrt( power((y2-y1), 2) + power((x2-x1), 2));
  if p = 0 then
    p := 1;
  l := ((X - x1)*(y2-y1)+(y1-y)*(x2-x1) ) / p;

  if abs(l) <= d then
    Result := true
  else
    Result := false;
end;

function GetValidRect(Point1, Point2: TPoint): TRect;
begin
  if Point1.X < Point2.X then
    Result.Left := Point1.X
  else
    Result.Left := Point2.X;

  if Point1.Y < Point2.Y then
    Result.Top := Point1.Y
  else
    Result.Top := Point2.Y;

  Result.Width := abs( Point2.X - Point1.X);
  Result.Height := abs( Point2.Y - Point1.Y);
end;

function GetValidRect(Points: TArray<TPoint>): TRect; overload
var
  I: Integer;
begin
  if Length( Points ) = 0 then
    Exit;

  Result.TopLeft := Points[0];
  Result.BottomRight := Points[0];

  for I := 1 to High(Points) do
    begin
      if Points[I].X < Result.Left then
        Result.Left := Points[I].X;
      if Points[I].Y < Result.Top then
        Result.Top := Points[I].Y;

      if Points[I].X > Result.Right then
        Result.Right := Points[I].X;
      if Points[I].Y > Result.Bottom then
        Result.Bottom := Points[I].Y;
    end;
end;

function GetValidRect(Rect: TRect): TRect;
begin
  if Rect.TopLeft.X < Rect.BottomRight.X then
    Result.Left := Rect.TopLeft.X
  else
    Result.Left := Rect.BottomRight.X;

  if Rect.TopLeft.Y < Rect.BottomRight.Y then
    Result.Top := Rect.TopLeft.Y
  else
    Result.Top := Rect.BottomRight.Y;

  Result.Width := abs( Rect.BottomRight.X - Rect.TopLeft.X);
  Result.Height := abs( Rect.BottomRight.Y - Rect.TopLeft.Y);
end;

procedure CenterRectInRect(var ARect: TRect; const ParentRect: TRect);
begin
  ARect.Offset((ParentRect.Width div 2 - ARect.Width div 2) - ARect.Left,
               (ParentRect.Height div 2 - ARect.Height div 2) - ARect.Top);
end;

procedure CenterRectAtPoint(var ARect: TRect; const APoint: TPoint);
var
  ACenter: TPoint;
begin
  ACenter := ARect.CenterPoint;
  ARect.Offset(APoint.X-ACenter.X, APoint.Y-ACenter.Y);
end;

function PointInRect(Point: TPoint; Rect: TRect): boolean;
begin
  Result := Rect.Contains(Point);
end;

procedure ContainRectInRect(var ARect: TRect; const ParentRect: TRect);
var
  Left, Top, Right, Bottom: integer;
begin
  Left := ParentRect.Left - ARect.Left;
  Top := ParentRect.Top - ARect.Top;
  Right := ParentRect.Right - ARect.Right;
  Bottom := ParentRect.Bottom - ARect.Bottom;

  if Left > 0 then
    ARect.Offset(Left, 0);
  if Top > 0 then
    ARect.Offset(0, Top);
  if Right < 0 then
    ARect.Offset(Right, 0);
  if Bottom < 0 then
    ARect.Offset(0, Bottom);
end;

function SetPositionAroundPoint(Point: TPoint; Center: TPoint; degree: real; customradius: real = -1): TPoint;
var
  r, dg, dsin, dcos: real;
begin
  dg := (degree * pi / 180);

  dsin := sin(dg);
  dcos := cos(dg);

  if customradius = -1 then
    r := Center.Distance(Point)
  else
    r := customradius;

  // Apply New Properties
  Result.X := round( Center.X + r * dsin );
  Result.Y := round( Center.Y + r * dcos );
end;

function PointAroundCenter(Center: TPoint; degree: real; customradius: real = -1): TPoint;
var
  r, dg, dsin, dcos: real;
begin
  dg := (degree * pi / 180);

  dsin := sin(dg);
  dcos := cos(dg);

  r := customradius;

  // Apply New Properties
  Result.X := round( Center.X + r * dsin );
  Result.Y := round( Center.Y + r * dcos );
end;

function RotatePointAroundPoint(APoint: TPoint; ACenter: TPoint; ARotateDegree: real; ACustomRadius: real): TPoint;
var
  r, dg, cosa, sina, ncos, nsin, dsin, dcos: real;
begin
  dg := (ARotateDegree * pi / 180);

  dsin := sin(dg);
  dcos := cos(dg);

  if ACustomRadius = -1 then
    r := ACenter.Distance(APoint)
  else
    r := ACustomRadius;

  if r <> 0 then
    begin
      cosa := (APoint.X - ACenter.X) / r;
      sina := (APoint.Y - ACenter.Y) / r;


      nsin := sina * dcos + dsin * cosa;
      ncos := cosa * dcos - sina * dsin;


      // Apply New Properties
      Result.X := round( ACenter.X + r * ncos );
      Result.Y := round( ACenter.Y + r * nsin );
    end;
end;

function PointAngle(APoint: TPoint; ACenter: TPoint; offset: integer): integer;
var
  alpha, r: real;
begin
  r := sqrt( Power(APoint.X - ACenter.X,2)+Power(APoint.Y - ACenter.Y,2) );

  if APoint.Y >= ACenter.Y then
    alpha := ArcCos( (APoint.X - ACenter.X) / r)
  else
    alpha := 2 * pi - ArcCos( (APoint.X - ACenter.X) / r);

  Result := offset + round(180 * alpha / pi);

  if offset <> 0 then
  begin
    if Result < 0 then
      Result := Result + 360;
    if Result > 360 then
      Result := Result - 360;
  end;
end;

function StringToBoolean(str: string): boolean;
begin
  if (AnsiLowerCase(str) = 'true') or (str = '1') or (str = '-1') then
    Result := true
  else
    Result := false;
end;

function BooleanToString(value: boolean): string;
begin
  if value then
    Result := 'true'
  else
    Result := 'false'
end;

function BooleanToYesNo(value: boolean): String;
begin
  if value then
    Result := 'yes'
  else
    Result := 'no'
end;

function IconToBitmap(icon: TIcon): TBitMap;
begin
  Result := TBitmap.Create;
  Result.Height := Icon.Height;
  Result.Width  := Icon.Width;
  Result.Canvas.Draw(0, 0, Icon);

  Result.Transparent := true;
  Result.TransparentMode := tmAuto;
end;

function IntToStrIncludePrefixZeros(Value: integer; NumbersCount: integer): string;
var
  ResLength: integer;
  I: Integer;
begin
  Result := IntToStr( abs(Value) );

  ResLength := Length( Result );
  if ResLength < NumbersCount then
    begin
      for I := 1 to NumbersCount - ResLength do
        Result := '0' + Result;

      if Value < 0 then
        Result := '-' + Result;
    end;
end;

function DecToHex(Dec: int64): string;
var
  I: Integer;
begin
  //result:= digits[Dec shr 4]+digits[Dec and $0F];
  Result := IntToHex(Dec);

  for I := 1 to length(Result) do
      if (Result[1] = '0') and (Length(Result) > 2) then
        Result := Result.Remove(0, 1)
      else
        Break;

  if Result = '' then
        Result := '00';
end;

function HexToDec(Hex: string): int64;
begin
  Result := StrToInt64('$' + Hex);
end;

function InArray(Value: integer; arrayitem: array of integer): integer; overload;
var
  I: integer;
begin
  Result := -1;
  for I := 0 to length(arrayitem) - 1 do
    if arrayitem[I] = Value then
    begin
      Result := I;
      Break;
    end;
end;

function InArray(Value: string; arrayitem: array of string): integer; overload;
var
  I: integer;
begin
  Result := -1;
  for I := 0 to length(arrayitem) - 1 do
    if arrayitem[I] = Value then
    begin
      Result := I;
      Break;
    end;
end;

procedure ShuffleArray(var arr: TArray<Integer>);
var
  i, j, temp: Integer;
begin
  // shuffle the array using Fisher-Yates algorithm
  for i := Length(arr) - 1 downto 1 do
  begin
    j := Random(i + 1); // generate a random index between 0 and i
    temp := arr[j];
    arr[j] := arr[i];
    arr[i] := temp;
  end;
end;

procedure ArrayAdd(Data: string; var AArray: TArray<string>; CheckDuplicate: boolean);
var
  AIndex: integer;
    I: Integer;
begin
  // Find Exists
  if CheckDuplicate then
    for I := 0 to High(AArray) do
      if Data = AArray[I] then
        Exit;

  // Add to array
  AIndex := Length(AArray);
  SetLength(AArray, AIndex+1);

  AArray[AIndex] := Data;
end;

procedure ArrayRemove(Data: string; var AArray: TArray<string>; RemoveAll: boolean);
var
  I, J: Integer;
begin
  // Find Exists
  for I := 0 to High(AArray) do
    if Data = AArray[I] then
      begin
        for J := I to High(AArray)-1 do
          AArray[J] := AArray[J+1];

        // Shrink Size
        SetLength(AArray, Length(AArray)-1);

        if not RemoveAll then
          Break;
      end;
end;

{ TRoundRect }

constructor TRoundRect.Create(TopLeft, BottomRight: TPoint; Rnd: integer);
begin
  Rect := TRect.Create(TopLeft, BottomRight);

  SetRoundness( Rnd );
end;

constructor TRoundRect.Create(SRect: TRect; Rnd: integer);
begin
  Rect := SRect;

  SetRoundness( Rnd );
end;

constructor TRoundRect.Create(Left, Top, Right, Bottom, Rnd: integer);
begin
  Rect := TRect.Create(Left, Top, Right, Bottom);

  SetRoundness( Rnd );
end;

function TRoundRect.Bottom: integer;
begin
  Result := Rect.Bottom;
end;

function TRoundRect.BottomRight: TPoint;
begin
  Result := Rect.BottomRight;
end;

function TRoundRect.GetRoundness: integer;
begin
  Result := round( (Self.RoundTL + Self.RoundTR + Self.RoundBL + Self.RoundBR) / 4 );
end;

function TRoundRect.Height: integer;
begin
  Result := Rect.Height;
end;

function TRoundRect.Left: integer;
begin
  Result := Rect.Left;
end;

procedure TRoundRect.Offset(const DX, DY: Integer);
begin
  Rect.Offset(DX, DY);
end;

function TRoundRect.Right: integer;
begin
  Result := Rect.Right;
end;

function TRoundRect.RoundX: integer;
begin
  Result := round( (Self.RoundTL + Self.RoundTR + Self.RoundBL + Self.RoundBR) / 4 );
end;

function TRoundRect.RoundY: integer;
begin
    Result := round( (Self.RoundTL + Self.RoundTR + Self.RoundBL + Self.RoundBR) / 4 );
end;

procedure TRoundRect.SetRoundness(Value: integer);
begin
  RoundTL := Value;
  RoundTR := Value;
  RoundBL := Value;
  RoundBR := Value;
end;

function TRoundRect.Top: integer;
begin
  Result := Rect.Top;
end;

function TRoundRect.TopLeft: TPoint;
begin
  Result := Rect.TopLeft;
end;

function TRoundRect.Width: integer;
begin
  Result := Rect.Width;
end;

{ TLine }

constructor TLine.Create(P1, P2: TPoint);
begin
  Point1 := P1;
  Point2 := P2;
end;

function TLine.GetHeight: integer;
begin
  Result := abs(Point1.Y - Point2.Y);
end;

function TLine.GetWidth: integer;
begin
  Result := abs(Point1.X - Point2.X);
end;

procedure TLine.OffSet(const DX, DY: Integer);
begin
  Inc( Point1.X, DX );
  Inc( Point1.Y, DY );
  Inc( Point2.X, DX );
  Inc( Point2.Y, DY );
end;

function TLine.Rect: TRect;
begin
  Result := GetValidRect(Point1, Point2);
end;

function TLine.Center: TPoint;
begin
  Result := Point( (Point1.X + Point2.X) div 2, (Point1.Y + Point2.Y) div 2);
end;

{ TIntegerList }

function IntegerListCompare(List: TIntegerList; Index1, Index2:
Integer): Integer;
begin
  if (List[Index1] < List[Index2]) then
    Result := -1
  else if (List[Index1] > List[Index2]) then
    Result := 1
  else
    Result := 0;
end;

function TIntegerList.Add(Item: Integer) : Integer;
begin
  if not Sorted then
    Result := FList.Count
  else
    if Find(Item, Result) then
      case Duplicates of
        dupIgnore : Exit;
//        dupError  : Error(@SDuplicateString, 0);
        dupError  : Exit;
      end;

  Insert(Result, Item);
end;

procedure TIntegerList.Clear;
begin
  FList.Clear;
end;

constructor TIntegerList.Create;
begin
  inherited;
  FList := TList.Create;
end;

procedure TIntegerList.Delete(Index: Integer);
begin
  FList.Delete(Index);
end;

destructor TIntegerList.Destroy;
begin
  FList.Free;

  inherited;
end;

procedure TIntegerList.Exchange(Index1, Index2: Integer);
begin
  FList.Exchange(Index1, Index2);
end;

function TIntegerList.Find(aValue: Integer; var Index: Integer):
Boolean;
var
  L, H, I, C: Integer;

  function IntegerCompare(aValue1, aValue2: Integer) : Integer;
  begin
    if (aValue1 < aValue2) then
      Result := -1
    else if (aValue1 > aValue2) then
      Result := 1
    else
      Result := 0;
  end;

begin
  Result := False;
  if Sorted then
    begin
      L := 0;
      H := FList.Count - 1;

      while (L <= H) do begin
        I := (L + H) shr 1;
        C := IntegerCompare(Items[I], aValue);

        if (C < 0) then
          L := I + 1
        else begin
          H := I - 1;

          if (C = 0) then begin
            Result := True;
            if (Duplicates <> dupAccept) then
              L := I;
          end;
        end;
      end;

      Index := L;
    end
      else
        for I := 0 to Count-1 do
          if Items[I] = aValue then
            begin
              Result := true;
              Index := I;
              Break;
            end;
end;

function TIntegerList.First(): Integer;
begin
  Result := Integer(FList.First());
end;

function TIntegerList.GetCapacity() : Integer;
begin
  Result := FList.Capacity;
end;

function TIntegerList.GetCount() : Integer;
begin
  Result := FList.Count;
end;

function TIntegerList.GetHigh: Integer;
begin
  Result := Count - 1;
end;

function TIntegerList.GetItems(Index: Integer): Integer;
begin
  Result := Integer(FList.Items[Index]);
end;

function TIntegerList.IndexOf(const Value: integer): integer;
begin
  if not Find( Value, Result ) then
    Result := -1;
end;

procedure TIntegerList.Insert(Index, Item: Integer);
begin
  FList.Insert(Index, Pointer(Item));
end;

function TIntegerList.Last() : Integer;
begin
  Result := Integer(FList.Last());
end;

procedure TIntegerList.LoadFromString(AString: string; Separator: string);
var
  P, E: integer;
begin
  if (AString = '') or (Separator = '') then
    Exit;

  AString := AString + Separator;

  Self.SetCount(0);
  P := 0;
  repeat
    E := Pos( Separator, AString, P + 1);

    if E > 0 then
      Self.Add( strtoint( Copy(AString, P+1, E - P-1) ) );

    P := E;
  until P = 0;
end;

procedure TIntegerList.Move(CurIndex, NewIndex: Integer);
begin
  FList.Move(CurIndex, NewIndex);
end;

procedure TIntegerList.Pack;
begin
  FList.Pack;
end;

procedure TIntegerList.QuickSort(L, R: Integer; SCompare:
TIntegerListSortCompare);
var
  I, J, P: Integer;
begin
  repeat
    I := L;
    J := R;
    P := (L + R) shr 1;

    repeat
      while (SCompare(Self, I, P) < 0) do
        Inc(I);

      while (SCompare(Self, J, P) > 0) do
        Dec(J);

      if (I <= J) then begin
        Exchange(I, J);

        if (P = I) then
          P := J
        else if (P = J) then
          P := I;

        Inc(I);
        Dec(J);
      end;
    until (I > J);

    if (L < J) then
      QuickSort(L, J, SCompare);
    L := I;
  until (I >= R);
end;

procedure TIntegerList.SetCapacity(const Value: Integer);
begin
  FList.Capacity := Value;
end;

procedure TIntegerList.SetCount(const Value: Integer);
begin
  FList.Count := Value;
end;

procedure TIntegerList.SetItems(Index: Integer; const Value: Integer);
begin
  FList.Items[Index] := Pointer(Value);
end;

procedure TIntegerList.SetSorted(const Value: Boolean);
begin
  if (FSorted <> Value) then begin
    if Value then
      Sort;
    FSorted := Value;
  end;
end;

procedure TIntegerList.Sort;
begin
  if not Sorted and (FList.Count > 1) then begin
//    Changing;
    QuickSort(0, FList.Count - 1, IntegerListCompare);
//    Changed;
  end;
end;

function TIntegerList.StringContents: string;
var
  I: Integer;
begin
  for I := 0 to Self.Count - 1 do
    Result := Result + inttostr( Self[I] ) + ',';
  Result := Copy( Result, 0, Length(Result) - 1 );
end;

{ THexByte }

{ T4PointPolygon }

function T4PointPolygon.Bottom: integer;
begin
  Result := ToRect.Bottom;
end;

function T4PointPolygon.Center: TPoint;
begin
  Result := ToRect.CenterPoint;
end;

constructor T4PointPolygon.Create(P1, P2, P3, P4: TPoint);
begin
  Point[1] := P1;
  Point[2] := P2;
  Point[3] := P3;
  Point[4] := P4;
end;

function T4PointPolygon.Left: integer;
begin
  Result := ToRect.Left;
end;

procedure T4PointPolygon.Offset(By: TPoint);
var
  I: Integer;
begin
  for I := Low(Point) to High(Point) do
    Point[I].Offset(By);
end;

procedure T4PointPolygon.Offset(X, Y: integer);
begin
  OffSet( TPoint.Create(X, Y) );
end;

function T4PointPolygon.Right: integer;
begin
  Result := ToRect.Right;
end;

procedure T4PointPolygon.Rotate(Degrees: real);
var
  C: TPoint;
  I: Integer;
begin
  C := Center;

  for I := Low(Point) to High(Point) do
    Point[I] := RotatePointAroundPoint(Point[I], C, Degrees);
end;

function T4PointPolygon.Top: integer;
begin
  Result := ToRect.Top;
end;

function T4PointPolygon.ToRect: TRect;
begin
  TRect.Union(Point);
end;

{ TLineF }

constructor TLineF.Create(P1, P2: TPointF);
begin
  Point1 := P1;
  Point2 := P2;
end;

function TLineF.GetHeight: single;
begin
  Result := abs(Point1.Y - Point2.Y);
end;

function TLineF.GetWidth: single;
begin
  Result := abs(Point1.X - Point2.X);
end;

procedure TLineF.OffSet(const DX, DY: single);
begin
  Point1.X := Point1.X + DX;
  Point1.Y := Point1.Y + DY;
  Point2.X := Point2.X + DX;
  Point2.Y := Point2.Y + DY;
end;

function TLineF.Rect: TRectF;
begin
  Result := TRectF.Create(Point1, Point2, true);
end;

function TLineF.Center: TPointF;
begin
  Result := PointF( (Point1.X + Point2.X) / 2, (Point1.Y + Point2.Y) / 2);
end;

end.
