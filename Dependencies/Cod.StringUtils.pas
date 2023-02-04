{***********************************************************}
{                  Codruts String Utilities                 }
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

unit Cod.StringUtils;

interface
  uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Math;

  type
    TStringFindFlag = (sffIgnoreCase, sffFoundOnce, sffFoundMultiple);
    TStringFindFlags = set of TStringFindFlag;

  // String Func
  function GetAllSeparatorItems(str: string; separators: TArray<string>): TArray<string>; overload;
  function GetAllSeparatorItems(str: string; separator: string = ','): TArray<string>; overload;
  function GenerateString(strlength: integer; letters: boolean = true;
                          capitalization: boolean = true; numbers: boolean = true;
                          symbols: boolean = true): string;


  // String Alterations
  function StrCopy(MainString: string; frompos, topos: integer; justcontent: boolean = false): string;
  function StrRemove(MainString: string; frompos, topos: integer): string;
  function StrReplZone(MainString: string; frompos, topos: integer; ReplaceWith: string): string;
  function StrInsert(MainString: string; AtPos: integer; InsertText: string): string;

  // String Search
  function StrCount(SubString: string; MainString: string): integer;
  function StrPos(SubString: string; MainString: string; index: integer = 1; offset: integer = 0; Flags: TStringFindFlags = []): integer;
  function InString(SubString, MainString: string; Flags: TStringFindFlags = []): boolean;

  // String List
  procedure InsertStListInStList(insertindex: integer; SubStrList: TStringList; var ParentStringList: TStringList);
  function StringToStringList(str: string): TStringList;
  function StringListToString(stringlist: TStringList): string;
  procedure ArrayToStringList(AArray: TArray<string>; var StringList: TStringList);

const
  allchars = ['0'..'9', 'a'..'z', 'A'..'Z', '~', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '-', '=', '+', '[', ']', '{', '}', ';', ':', '"', '\', '|', '<', '>', ',', '.', '/', '?', ' '];
  symbolchars : TArray<String> = ['~', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '-', '=', '+', '[', ']', '{', '}', ';', ':', '"', '\', '|', '<', '>', ',', '.', '/', '?'];

implementation

function GenerateString(strlength: integer; letters, capitalization,
  numbers, symbols: boolean): string;
var
  I, A: Integer;
  F: string;
begin
  for I := 1 to strlength do
  begin
    Randomize();

    F := '';

    if (NOT letters) and (NOT numbers) and (NOT symbols) then
      Exit;


    repeat
      A := Random(3);

      case A of
        0: if letters then
            F := Chr(ord('a') + Random(26));
        1: if numbers then
            F := inttostr(randomrange(0,9));
        2: if symbols then
            F := symbolchars[Random(length(symbolchars))];
      end;

    until (F <> '');

    if (Random(2) = 1) and capitalization then
      F := ANSIUpperCase(F);

    Result := Result + F;
  end;
end;

function GetAllSeparatorItems(str: string; separators: TArray<string>): TArray<string>;
var
  P, N, I, SeparLength: integer;
begin
  SetLength(Result, 0);

  N := -1;
  repeat
    // Item 0
    P := Pos(separators[0], str);
    SeparLength := length( separators[0] );

    for I := 1 to High( separators ) do
      begin
        N := Pos(separators[I], str);
        if (N > 0) and (N < P) then
          begin
            P := N;
            SeparLength := length( separators[I] );
          end;
      end;

    // Exit
    if P = 0 then
      begin
        SetLength(Result, Length(Result) + 1);
        Result[N + 1] := str;

        Break;
      end;

    // Add
    N := Length( Result );
    SetLength(Result, N + 1);

    Result[N] := StrCopy(str, 0, P - 1);

    // Delete
    str := StrRemove(str, 0, P + SeparLength - 1);
  until P = 0;
end;

function GetAllSeparatorItems(str: string; separator: string = ','): TArray<string>; overload;
begin
  Result := GetAllSeparatorItems( str, [separator]);
end;


function StrRemove(MainString: string; frompos, topos: integer): string;
begin
  Result := Copy(mainstring, 1, frompos - 1)
    + Copy(mainstring, topos + 1, length(mainstring));
end;

function StrReplZone(MainString: string; frompos, topos: integer; ReplaceWith: string): string;
begin
    Result := Copy(mainstring, 1, frompos - 1) + ReplaceWith
    + Copy(mainstring, topos + 1, length(mainstring));
end;

function StrInsert(MainString: string; AtPos: integer; InsertText: string): string;
begin
  Result := Copy(mainstring, 1, AtPos - 1) + InsertText
    + Copy(mainstring, AtPos, length(mainstring));
end;

function StrCount(SubString: string; MainString: string): integer;
var
  P: integer;
begin
  Result := 0;
  while Pos(substring, mainstring) <> 0 do
    begin
      P := Pos(substring, mainstring);
      mainstring := Copy(mainstring, P + 1, length(mainstring) );

      inc(Result);
    end;
end;

function StrPos(SubString: string; MainString: string; index: integer; offset: integer; Flags: TStringFindFlags): integer;
var
  I, L, offs: Integer;
begin
  // Flags
  if sffIgnoreCase in Flags then
    begin
      MainString := AnsiLowerCase( MainString );
      SubString := AnsiLowerCase( SubString );
    end;

  // Prepare
  Result := 0;
  L := 0;

  // Find by index
  for I := 1 to index do
  begin
    offs := Result + 1;
    if I = 1 then
      offs := offs + offset;

    Result := Pos(substring, mainstring, offs);

    if Result < L then
    begin
      Break;
      Result := 0;
    end;

    L := Result;
  end;
end;

function InString(SubString, MainString: string; Flags: TStringFindFlags = []): boolean;
var
  Found, CPos: integer;
begin
  if sffIgnoreCase in Flags then
    begin
      substring := AnsiLowerCase(substring);
      substring := AnsiLowerCase(substring);
    end;

  // Get Count
  Found := 0;
  CPos := 0;
  repeat
    CPos := Pos(SubString, MainString, CPos + 1);

    if CPos <> 0 then
      Inc(Found)

  until (CPos = 0) or not ((sffFoundOnce in Flags) or (sffFoundMultiple in Flags));

  // Flags Search
  if not ((sffFoundOnce in Flags) or (sffFoundMultiple in Flags)) then
    Result := Found <> 0
  else
    begin
      if sffFoundOnce in Flags then
        Result := Found = 1
      else
        Result := Found > 1;
    end;
end;

function StrCopy(MainString: string; frompos, topos: integer; justcontent: boolean): string;
begin
  if justcontent then
    begin
      frompos := frompos + 1;
      topos := topos - 1;
    end;
  if frompos < 1 then
    frompos := 1;
  Result := Copy(mainstring, frompos, topos - frompos + 1);
end;

procedure InsertStListInStList(insertindex: integer; SubStrList: TStringList; var ParentStringList: TStringList);
var
  I: Integer;
begin
  for I := 0 to SubStrList.Count - 1 do
    ParentStringList.Insert(insertindex + I, SubStrList[I]);
end;

function StringToStringList(str: string): TStringList;
var
  P: integer;
begin
  Result := TStringList.Create;

  repeat
    P := Pos(#13, str);

    if P = 0 then
      begin
        Result.Add(str);

        Break;
      end;

    Result.Add( StrCopy(str, 0, P - 1) );

    str := StrRemove(str, 0, P);
  until P = 0;
end;

function StringListToString(stringlist: TStringList): string;
var
  I: Integer;
begin
  for I := 0 to stringlist.Count - 1 do
    begin
      Result := Result + stringlist[I];

      if I < stringlist.Count - 1 then
        Result := Result + #13;
    end;
end;

procedure ArrayToStringList(AArray: TArray<string>; var StringList: TStringList);
var
  I: Integer;
begin
  StringList.Clear;
  for I := 0 to length( AArray ) - 1 do
    StringList.Add( AArray[I] );
end;




end.