{***********************************************************}
{                  Codruts Variabile Helpers                }
{                                                           }
{                        version 1.0                        }
{                           ALPHA                           }
{                                                           }
{              https://www.codrutsoft.com/                  }
{             Copyright 2024 Codrut Software                }
{    This unit is licensed for usage under a MIT license    }
{                                                           }
{***********************************************************}

{$SCOPEDENUMS ON}

unit Cod.ArrayHelpers;

interface
uses
  System.SysUtils, System.Classes, Types, Math,
  System.Generics.Collections, System.Generics.Defaults;

type
  /// Note about internal errors
  ///  This class uses lComparer to compare values because some value types,
  ///  such as record cannot be directly compared and would give the
  ///  "Invalid operand type" error, but since this class is type based,
  ///  a internal error would appear instead.

  // TArray colection
  TArrayUtils<T> = class
  public
    // Callback types
    type
    TArrayEachCallback = reference to procedure(var Element: T);
    TArrayEachCallbackConst = reference to procedure(Element: T);
    TArrayDualCallback = reference to function(A, B: T): TValueRelationship;
    TArrayIndexCallback = reference to function(Index: integer): T;
    TArrayFindItemCallback = reference to function(Element: T): boolean;

    /// <summary> Verify if the array contains element x. </summary>
    class function Build(const Length: integer; Callback: TArrayIndexCallback): TArray<T>;

    /// <summary> Verify if the array contains element x. </summary>
    class function Contains(const x: T; const Values: TArray<T>): boolean; overload;
    /// <summary> Verify if the array contains element x. </summary>
    class function ContainsAny(const Search: TArray<T>; const Values: TArray<T>): boolean; overload;
    /// <summary> Verify if the array contains an element with a verify callback. </summary>
    class function Contains(const Values: TArray<T>; Callback: TArrayFindItemCallback): boolean; overload;
    /// <summary> Compares is two arrays are equal. </summary>
    class function CheckEquality(const First, Second: TArray<T>) : boolean;

    /// <summary> Create a copy of the array. </summary>
    class function CreateCopy(const Source: TArray<T>): TArray<T>;
    /// <summary> Create a copy of the array. </summary>
    class procedure CopyTo(const Source: TArray<T>; var Destination: TArray<T>);

    /// <summary> Get the index if element x. </summary>
    class function GetIndex(const x: T; const Values: TArray<T>): integer; overload;
    /// <summary> Get the index if element with a callback to see if the item was found. </summary>
    class function GetIndex(const Values: TArray<T>; Callback: TArrayFindItemCallback): integer; overload;
    /// <summary> Go trough all elements of an array and get their value. </summary>
    class procedure ForEach(const Values: TArray<T>; Callback: TArrayEachCallbackConst); overload;
    /// <summary> Go trough all elements of an array and modify their value. </summary>
    class procedure ForEach(var Values: TArray<T>; Callback: TArrayEachCallback); overload;
    /// <summary> Sort the elements of an array using the valid type IComparer for that type. </summary>
    class procedure SortGeneric(var Values: TArray<T>); overload;
    /// <summary> Sort the elements of an array using the provided callback for comparison. </summary>
    class procedure Sort(var Values: TArray<T>; const Callback: TArrayDualCallback); overload;
    /// <summary> Flip the array values Top-Bottom. </summary>
    class procedure Flip(var Values: TArray<T>); overload;

    /// <summary> Move one item from It's index to another item's index and moving that one uppwards. </summary>
    class procedure Move(var Values: TArray<T>; const Source, Destination: integer); overload;
    /// <summary> Switch places for two items. </summary>
    class procedure Switch(var Values: TArray<T>; const Source, Destination: integer); overload;

    /// <summary> Shuffle array to random position. </summary>
    class procedure Shuffle(var Values: TArray<T>); overload;

    /// <summary> Add blank value to the end of the array. </summary>
    class function AddValue(var Values: TArray<T>) : integer; overload;
    /// <summary> Add value to the end of the array. </summary>
    class function AddValue(const Value: T; var Values: TArray<T>) : integer; overload;
    /// <summary> Add value to the end of the array. </summary>
    class procedure AddValues(const Values: TArray<T>; var Destination: TArray<T>);
    /// <summary> Add value to the end of the array if It;s not in the array allready. </summary>
    class function AddValueUnique(const Value: T; var Values: TArray<T>) : integer; overload;
    /// <summary> Concat secondary array to primary array </summary>
    class function Concat(const Primary, Secondary: TArray<T>) : TArray<T>;
    /// <summary> Insert empty value at the specified index into the array. </summary>
    class procedure Insert(const Index: integer; var Values: TArray<T>); overload;
    /// <summary> Insert value at the specified index into the array. </summary>
    class procedure Insert(const Index: integer; const Value: T; var Values: TArray<T>); overload;

    /// <summary> Delete element by index from array. </summary>
    class procedure Delete(const Index: integer; var Values: TArray<T>);
    /// <summary> Delete element by type T from array. </summary>
    class procedure DeleteValue(const Value: T; var Values: TArray<T>);
    /// <summary> Set length to specifieed value. </summary>
    ///
    class procedure SetLength(const Length: integer; var Values: TArray<T>);
    /// <summary> Get array length. </summary>
    class function Count(const Values: TArray<T>) : integer;

    (* Known algorithms *)
    /// <summary> Quick sort algorithm, </summary>
    class procedure DoQuickSort(var Values: TArray<T>; const Callback: TArrayDualCallback; Left, Right: Integer);
    /// <summary> Quick sort algorithm, </summary>
    class procedure DoFisherYatesShuffle(var Values: TArray<T>; Left, Right: Integer);
  end;

  // Generic type helpers
  TStringArray = TArray<string>;
  TStringArrayHelper = record helper for TStringArray
  public
    function AddValue(Value: string): integer;
    procedure Insert(Index: integer; Value: string);
    procedure Delete(Index: integer);
    function Count: integer; overload; inline;
    function Find(Value: string): integer;
    procedure SetToLength(ALength: integer);
  end;

  TIntArray = TArray<integer>;
  TIntegerArrayHelper = record helper for TIntArray
  public
    function AddValue(Value: integer): integer;
    procedure Insert(Index: integer; Value: integer);
    procedure Delete(Index: integer);
    function Count: integer; overload; inline;
    function Find(Value: integer): integer;
    procedure SetToLength(ALength: integer);
  end;

  TRealArray = TArray<real>;
  TRealArrayHelper = record helper for TRealArray
  public
    function AddValue(Value: real): integer;
    procedure Insert(Index: integer; Value: real);
    procedure Delete(Index: integer);
    function Count: integer; overload; inline;
    function Find(Value: real): integer;
    procedure SetToLength(ALength: integer);
  end;

  TCharArray = TArray<char>;
  TCharArrayHelper = record helper for TCharArray
  public
    function AddValue(Value: char): integer;
    procedure Insert(Index: integer; Value: char);
    procedure Delete(Index: integer);
    function Count: integer; overload; inline;
    function Find(Value: char): integer;
    procedure SetToLength(ALength: integer);
  end;

  TBoolArray = TArray<boolean>;
  TBoolArrayHelper = record helper for TBoolArray
  public
    function AddValue(Value: boolean): integer;
    procedure Insert(Index: integer; Value: boolean);
    procedure Delete(Index: integer);
    function Count: integer; overload; inline;
    function Find(Value: boolean): integer;  // pretty useless, but can find if a value exists
    procedure SetToLength(ALength: integer);
  end;

implementation

{ TArrayUtils<T> }

class function TArrayUtils<T>.AddValue(const Value: T;
  var Values: TArray<T>): integer;
begin
  Result := AddValue(Values);
  Values[Result] := Value;
end;

class function TArrayUtils<T>.AddValue(var Values: TArray<T>): integer;
begin
  System.SetLength(Values, length(Values)+1);

  Result := High(Values);
end;

class procedure TArrayUtils<T>.AddValues(const Values: TArray<T>;
  var Destination: TArray<T>);
begin
  const StartIndex = High(Destination)+1;
  System.SetLength(Destination, length(Destination)+length(Values));

  const LowPoint = Low(Values);
  for var I := LowPoint to High(Values) do
    Destination[StartIndex+I-LowPoint] := Values[I];
end;

class function TArrayUtils<T>.AddValueUnique(const Value: T;
  var Values: TArray<T>): integer;
begin
  Result := -1;
  if not Contains(Value, Values) then
    Result := AddValue(Value, Values);
end;

class function TArrayUtils<T>.Build(const Length: integer;
  Callback: TArrayIndexCallback): TArray<T>;
begin
  System.SetLength(Result, Length);
  for var I := 0 to Length-1 do
    Result[I] := Callback(I);
end;

class function TArrayUtils<T>.Concat(const Primary,
  Secondary: TArray<T>): TArray<T>;
begin
  Result := Primary;

  AddValues(Secondary, Result);
end;

class function TArrayUtils<T>.Contains(const Values: TArray<T>;
  Callback: TArrayFindItemCallback): boolean;
begin
  Result := false;
  for var I := 0 to High(Values) do
    if Callback( Values[I] ) then
      Exit(true);
end;

class function TArrayUtils<T>.ContainsAny(const Search,
  Values: TArray<T>): boolean;
begin
  Result := false;
  for var I := 0 to High(Values) do
    if Contains( Values[I], Search ) then
      Exit(true);
end;

class procedure TArrayUtils<T>.CopyTo(const Source: TArray<T>;
  var Destination: TArray<T>);
begin
  Destination := Copy(Source, 0, Length(Source));
end;

class function TArrayUtils<T>.Contains(const x: T; const Values: TArray<T>): boolean;
var
  y : T;
  lComparer: IEqualityComparer<T>;
begin
  lComparer := TEqualityComparer<T>.Default;
  for y in Values do
  begin
    if lComparer.Equals(x, y) then
      Exit(True);
  end;
  Exit(False);
end;

class function TArrayUtils<T>.Count(const Values: TArray<T>): integer;
begin
  Result := Length(Values);
end;

class function TArrayUtils<T>.CreateCopy(const Source: TArray<T>): TArray<T>;
begin
  Result := Copy(Source, 0, Length(Source));
end;

class procedure TArrayUtils<T>.Delete(const Index: integer;
  var Values: TArray<T>);
begin
  if Index = -1 then
    Exit;

  for var I := Index to High(Values)-1 do
    Values[I] := Values[I+1];

  System.SetLength(Values, Length(Values)-1);
end;

class procedure TArrayUtils<T>.DeleteValue(const Value: T;
  var Values: TArray<T>);
begin
  const Index = GetIndex(Value, Values);
  if Index <> -1 then
    Delete(Index, Values);
end;

class function TArrayUtils<T>.CheckEquality(const First, Second: TArray<T>): boolean;
var
  lComparer: IEqualityComparer<T>;
begin
  Result := true;
  lComparer := TEqualityComparer<T>.Default;

  if Length(First) <> Length(Second) then
    Exit(false);
  const Count = Length(First);
  for var I := 0 to Count-1 do
    if not lComparer.Equals(First[I], Second[I]) then
      Exit(false);
end;

class procedure TArrayUtils<T>.DoFisherYatesShuffle(var Values: TArray<T>; Left,
  Right: Integer);
var
  I, J: Integer;
  Temp: T;
begin
  Randomize;

  for I := Right downto Left + 1 do
  begin
    J := Random(I - Left + 1) + Left;

    // Swap values
    Temp := Values[I];
    Values[I] := Values[J];
    Values[J] := Temp;
  end;
end;

class procedure TArrayUtils<T>.Flip(var Values: TArray<T>);
var
  AHigh: integer;
  AMiddle: integer;
  Temp: T;
begin
  AHigh := High(Values);
  AMiddle := AHigh div 2;
  for var I := 0 to AMiddle do begin
    Temp := Values[I];
    Values[I] := Values[AHigh-I];
    Values[AHigh-I] := Temp;
  end;

end;

class procedure TArrayUtils<T>.ForEach(var Values: TArray<T>;
  Callback: TArrayEachCallback);
begin
  for var I := Low(Values) to High(Values) do
    Callback( Values[I] );
end;

class function TArrayUtils<T>.GetIndex(const Values: TArray<T>;
  Callback: TArrayFindItemCallback): integer;
begin
  Result := -1;
  for var I := 0 to High(Values) do
    if Callback( Values[I] ) then
      Exit(I);
end;

class procedure TArrayUtils<T>.ForEach(const Values: TArray<T>;
  Callback: TArrayEachCallbackConst);
var
  y : T;
begin
  for y in Values do
    Callback(y);
end;

class function TArrayUtils<T>.GetIndex(const x: T; const Values: TArray<T>): integer;
var
  I: Integer;
  y: T;
  lComparer: IEqualityComparer<T>;
begin
  lComparer := TEqualityComparer<T>.Default;
  for I := Low(Values) to High(Values) do
    begin
      y := Values[I];

      if lComparer.Equals(x, y) then
        Exit(I);
    end;
    Exit(-1);
end;

class procedure TArrayUtils<T>.Insert(const Index: integer;
  var Values: TArray<T>);
var
  Size: integer;
  I: Integer;
begin
  System.SetLength(Values, Length(Values)+1);
  Size := High(Values);

  for I := Size downto Index+1 do
    Values[I] := Values[I-1];
end;

class procedure TArrayUtils<T>.Insert(const Index: integer; const Value: T;
  var Values: TArray<T>);
begin
  Insert(Index, Values);

  // Set
  Values[Index] := Value;
end;

class procedure TArrayUtils<T>.Move(var Values: TArray<T>; const Source,
  Destination: integer);
var
  I: integer;
begin
  const OriginalItem = Values[Source];

  // Move all items
  if Source < Destination then begin
    for I := Source to Destination-1 do
      Values[I] := Values[I+1];
  end else begin
    for I := Source downto Destination+1 do
      Values[I] := Values[I-1];
  end;

  // Item
  Values[Destination] := OriginalItem;
end;

class procedure TArrayUtils<T>.DoQuickSort(var Values: TArray<T>;
  const Callback: TArrayDualCallback; Left, Right: Integer);
var
  Lower, Upper: Integer;
  Pivot, Temp: T;
begin
  if Right - Left = 0 then
    Exit;

  Lower := Left;
  Upper := Right;
  Pivot := Values[(Left + Right) div 2]; // Choosing middle item as pivot

  repeat
    // Move Lower right while Values[Lower] < Pivot and ensure Lower stays within bounds
    while (Lower <= Right) and (Callback(Values[Lower], Pivot) = LessThanValue) do
      Inc(Lower);

    // Move Upper left while Values[Upper] > Pivot and ensure Upper stays within bounds
    while (Upper >= Left) and (Callback(Values[Upper], Pivot) = GreaterThanValue) do
      Dec(Upper);

    if Lower <= Upper then begin
      // Swap Values[Lower] and Values[Upper]
      Temp := Values[Lower];
      Values[Lower] := Values[Upper];
      Values[Upper] := Temp;

      Inc(Lower);
      Dec(Upper);
    end;
  until Lower > Upper;

  // Recursively sort the sub-arrays
  if Left < Upper then
    DoQuickSort(Values, Callback, Left, Upper);
  if Lower < Right then
    DoQuickSort(Values, Callback, Lower, Right);
end;

class procedure TArrayUtils<T>.SetLength(const Length: integer;
  var Values: TArray<T>);
begin
  System.SetLength(Values, Length);
end;

class procedure TArrayUtils<T>.Shuffle(var Values: TArray<T>);
begin
  if Length(Values) > 1 then
    DoFisherYatesShuffle(Values, 0, Length(Values) - 1);
end;

class procedure TArrayUtils<T>.SortGeneric(var Values: TArray<T>);
var
  lComparer: IComparer<T>;
begin
  lComparer := TComparer<T>.Default;

  Sort(Values, function(A, B: T): TValueRelationship begin
    Result := lComparer.Compare(A, B);
  end);
end;

class procedure TArrayUtils<T>.Sort(var Values: TArray<T>;
  const Callback: TArrayDualCallback);
begin
  DoQuickSort(Values, Callback, 0, Length(Values) - 1);
end;

class procedure TArrayUtils<T>.Switch(var Values: TArray<T>; const Source,
  Destination: integer);
begin
  const OriginalItem = Values[Source];
  Values[Source] := Values[Destination];
  Values[Destination] := OriginalItem;
end;

// TArray Generic Helpers
function TStringArrayHelper.Count: integer;
begin
  Result := length(Self);
end;

function TIntegerArrayHelper.Count: integer;
begin
  Result := length(Self);
end;

function TRealArrayHelper.Count: integer;
begin
  Result := length(Self);
end;

procedure TStringArrayHelper.SetToLength(ALength: integer);
begin
  SetLength(Self, ALength);
end;

procedure TIntegerArrayHelper.SetToLength(ALength: integer);
begin
  SetLength(Self, ALength);
end;

procedure TRealArrayHelper.SetToLength(ALength: integer);
begin
  SetLength(Self, ALength);
end;

function TStringArrayHelper.AddValue(Value: string): integer;
var
  AIndex: integer;
begin
  AIndex := Length(Self);
  SetLength(Self, AIndex + 1);
  Self[AIndex] := Value;
  Result := AIndex;
end;

function TIntegerArrayHelper.AddValue(Value: integer): integer;
var
  AIndex: integer;
begin
  AIndex := Length(Self);
  SetLength(Self, AIndex + 1);
  Self[AIndex] := Value;
  Result := AIndex;
end;

function TRealArrayHelper.AddValue(Value: real): integer;
var
  AIndex: integer;
begin
  AIndex := Length(Self);
  SetLength(Self, AIndex + 1);
  Self[AIndex] := Value;
  Result := AIndex;
end;

procedure TStringArrayHelper.Insert(Index: integer; Value: string);
var
  Size: integer;
  I: Integer;
begin
  Size := Length(Self);
  SetLength(Self, Size+1);

  for I := Size downto Index+1 do
    Self[I] := Self[I-1];
  Self[Index] := Value;
end;

procedure TIntegerArrayHelper.Insert(Index: integer; Value: integer);
var
  Size: integer;
  I: Integer;
begin
  Size := Length(Self);
  SetLength(Self, Size+1);

  for I := Size downto Index+1 do
    Self[I] := Self[I-1];
  Self[Index] := Value;
end;

procedure TRealArrayHelper.Insert(Index: integer; Value: real);
var
  Size: integer;
  I: Integer;
begin
  Size := Length(Self);
  SetLength(Self, Size+1);

  for I := Size downto Index+1 do
    Self[I] := Self[I-1];
  Self[Index] := Value;
end;

procedure TStringArrayHelper.Delete(Index: integer);
var
  I: Integer;
begin
  if Index <> -1 then
    begin
      for I := Index to High(Self)-1 do
        Self[I] := Self[I+1];

      SetToLength(Length(Self)-1);
    end;
end;

procedure TIntegerArrayHelper.Delete(Index: integer);
var
  I: Integer;
begin
  if Index <> -1 then
    begin
      for I := Index to High(Self)-1 do
        Self[I] := Self[I+1];

      SetToLength(Length(Self)-1);
    end;
end;

procedure TRealArrayHelper.Delete(Index: integer);
var
  I: Integer;
begin
  if Index <> -1 then
    begin
      for I := Index to High(Self)-1 do
        Self[I] := Self[I+1];

      SetToLength(Length(Self)-1);
    end;
end;

function TStringArrayHelper.Find(Value: string): integer;
var
  I: integer;
begin
  Result := -1;
  for I := Low(Self) to High(Self) do
    if Self[I] = Value then
      Exit(I);
end;

function TIntegerArrayHelper.Find(Value: integer): integer;
var
  I: integer;
begin
  Result := -1;
  for I := Low(Self) to High(Self) do
    if Self[I] = Value then
      Exit(I);
end;

function TRealArrayHelper.Find(Value: real): integer;
var
  I: integer;
begin
  Result := -1;
  for I := Low(Self) to High(Self) do
    if Self[I] = Value then
      Exit(I);
end;

{ TBoolArrayHelper }

function TBoolArrayHelper.AddValue(Value: boolean): integer;
var
  AIndex: integer;
begin
  AIndex := Length(Self);
  SetLength(Self, AIndex + 1);
  Self[AIndex] := Value;
  Result := AIndex;
end;

function TBoolArrayHelper.Count: integer;
begin
  Result := length(Self);
end;

procedure TBoolArrayHelper.Delete(Index: integer);
var
  I: Integer;
begin
  if Index <> -1 then
    begin
      for I := Index to High(Self)-1 do
        Self[I] := Self[I+1];

      SetToLength(Length(Self)-1);
    end;
end;

function TBoolArrayHelper.Find(Value: boolean): integer;
var
  I: integer;
begin
  Result := -1;
  for I := Low(Self) to High(Self) do
    if Self[I] = Value then
      Exit(I);
end;

procedure TBoolArrayHelper.Insert(Index: integer; Value: boolean);
var
  Size: integer;
  I: Integer;
begin
  Size := Length(Self);
  SetLength(Self, Size+1);

  for I := Size downto Index+1 do
    Self[I] := Self[I-1];
  Self[Index] := Value;
end;

procedure TBoolArrayHelper.SetToLength(ALength: integer);
begin
  SetLength(Self, ALength);
end;

{ TCharArrayHelper }

function TCharArrayHelper.AddValue(Value: char): integer;
var
  AIndex: integer;
begin
  AIndex := Length(Self);
  SetLength(Self, AIndex + 1);
  Self[AIndex] := Value;
  Result := AIndex;
end;

function TCharArrayHelper.Count: integer;
begin
  Result := length(Self);
end;

procedure TCharArrayHelper.Delete(Index: integer);
var
  I: Integer;
begin
  if Index <> -1 then
    begin
      for I := Index to High(Self)-1 do
        Self[I] := Self[I+1];

      SetToLength(Length(Self)-1);
    end;
end;

function TCharArrayHelper.Find(Value: char): integer;
var
  I: integer;
begin
  Result := -1;
  for I := Low(Self) to High(Self) do
    if Self[I] = Value then
      Exit(I);
end;

procedure TCharArrayHelper.Insert(Index: integer; Value: char);
var
  Size: integer;
  I: Integer;
begin
  Size := Length(Self);
  SetLength(Self, Size+1);

  for I := Size downto Index+1 do
    Self[I] := Self[I-1];
  Self[Index] := Value;
end;

procedure TCharArrayHelper.SetToLength(ALength: integer);
begin
  SetLength(Self, ALength);
end;

end.