{***********************************************************}
{                    Codruts Time Utilities                 }
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

unit Cod.Math;
{$SCOPEDENUMS ON}

interface
  uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Math,
  Cod.SysUtils, System.Generics.Collections, Cod.VarHelpers, Cod.StringUtils,
  Cod.Types;

  // This function gets a string and automaticly calculates any
  // indics such as =time =eq = cell
  function GetParanthStart(from: integer; InText: string;
    paranthtype: char = '('): integer;
  // Get the first paranthes
  function GetParanthEnd(parastart: integer; InText: string;
    FindOnEmpty: boolean = true; p1type: char = '('; p2type: char = ')'): integer;
  // This function gets the end of a praranth. Ex: "=cell( =eq( cell(1,2) ), 4)"
  // to get the one assigned to the first one

  function SolveStringEcuation(Ecuation: string): real;
  // This function solves a ecuation written in string format

  function GetLocalePeriod: string;
  // This function finds out if the computer uses , or . for periods

  function StringToFloat(str: string): Extended;
  // Better string to float conversion

  // Number Sequences
  // Fisher-Yates shuffle algorithm
  function GenerateRandomSequence(count: Integer): TArray<Integer>;

  // Basic Mathematical Function
  function Sign(Value: integer): integer;
  function EqualApprox(number1, number2: int64; span: real = 1): boolean; overload;
  function EqualApprox(number1, number2: real; span: real = 1): boolean; overload;
  function PercOf(number: int64; percentage: integer): integer;
  function PercOfR(number: Real; percentage: int64): real;
  function GetNumberRelation(Primary, Secondary: int64): TRelation; overload;
  function GetNumberRelation(Primary, Secondary: real): TRelation; overload;
  {$IFDEF WIN32}
  procedure ConstraintASM(var Number: integer; Min: integer; Max: integer);
  {$ENDIF}
  procedure Constraint(var Number: integer; Min: integer = integer.MinValue; Max: integer = integer.MaxValue); overload;
  procedure Constraint(var Number: int64; Min: int64 = int64.MinValue; Max: int64 = int64.MaxValue); overload;
  procedure Constraint(var Number: Real; Min: Real = int64.MinValue; Max: Real = int64.MaxValue); overload;

const
    num_digit: TArray<char> = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
    num_content: TArray<char> = [',', '.','1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
    add_indic: TArray<char> = ['+', '-'];
    multp_indic: TArray<char> = ['*', '/'];
    oper_indic: TArray<char> = ['+', '-', '*', '/'];

implementation

function GetLocalePeriod: string;
var
  fs: TFormatSettings;
begin
  {$WARN SYMBOL_PLATFORM OFF}
  fs := TFormatSettings.Create(GetThreadLocale());
  {$WARN SYMBOL_PLATFORM ON}
  Result := fs.DecimalSeparator;
end;

function GenerateRandomSequence(count: Integer): TArray<Integer>;
var
  i, j, temp: Integer;
begin
  // create an array to hold the sequence
  SetLength(Result, count);

  // fill the array with sequential numbers
  for i := 0 to count - 1 do
    Result[i] := i + 1;

  // shuffle the sequence using Fisher-Yates algorithm
  for i := count - 1 downto 1 do
  begin
    j := Random(i + 1); // generate a random index between 0 and i
    temp := Result[j];
    Result[j] := Result[i];
    Result[i] := temp;
  end;
end;

function Sign(Value: integer): integer;
begin
  Result := Value div abs(Value);
end;

function EqualApprox(number1, number2: int64; span: real): boolean;
begin
  if (number1 <= number2 + span) and (number1 >= number2 - span) then
    Result := true
  else
    Result := false;
end;

function EqualApprox(number1, number2: real; span: real): boolean;
begin
  if (number1 <= number2 + span) and (number1 >= number2 - span) then
    Result := true
  else
    Result := false;
end;

function PercOf(number: int64; percentage: integer): integer;
begin
  Result := trunc(percentage / 100 * number);
end;

function PercOfR(number: Real; percentage: int64): real;
begin
  Result := percentage / 100 * number;
end;

function GetNumberRelation(Primary, Secondary: int64): TRelation;
begin
  Result := GetNumberRelation( real(Primary), real(Secondary) );
end;

function GetNumberRelation(Primary, Secondary: real): TRelation;
begin
  if Primary = Secondary then
    Result := TRelation.Equal
      else
        if Primary > Secondary then
          Result := TRelation.Bigger
            else
              Result := TRelation.Smaller;
end;

{$IFDEF WIN32}
procedure ConstraintASM(var Number: integer; Min: integer; Max: integer);
label
  min_succeed, min_analise, max_begin, max_succeed, write_value, exit_comp;
asm
    // Load values
    mov ebx, Min
    mov ecx, Max

    // Load registry location
    lea edx, [Number]

    // Load value
    mov eax, [edx]

    // Min
    cmp eax, ebx
    jle min_analise

    jmp max_begin

  min_analise:
    je exit_comp
    mov eax, ebx
    jmp write_value

    // Max
  max_begin:
    cmp eax, ecx
    jle exit_comp

    mov eax, ecx

    // Write
  write_value:
    mov [edx], eax

    // Exit
  exit_comp:
end;
{$ENDIF}

procedure Constraint(var Number: integer; Min: integer; Max: integer);
begin
  if Number < Min then
    Number := Min;

  if Number > Max then
    Number := Max;
end;

procedure Constraint(var Number: int64; Min: int64; Max: int64);
begin
  if Number < Min then
    Number := Min;

  if Number > Max then
    Number := Max;
end;

procedure Constraint(var Number: Real; Min: Real; Max: Real);
begin
  if Number < Min then
    Number := Min;

  if Number > Max then
    Number := Max;
end;

function StringToFloat(str: string): Extended;
var
  I: Integer;
  il: string;
begin
  il := '';
  for I := 1 to length(str) do
    if TArrayUtils<char>.Contains(str[I], add_indic) then
      il := il + str[I]
    else
      begin
        if length(il) > 1 then
          begin
            il := il.Replace('+', '');

            if length(il) mod 2 = 1 then
              str := StrReplZone(str, 0, I-1, '-')
            else
              str := StrRemove(str, 0, I-1);
          end;

        Break;
      end;

  Result := StrToFloat(str);
end;

function GetParanthStart(from: integer; InText: string; paranthtype: char): integer;
var
  spar: char;
begin
  spar := paranthtype; { Parantheses type }

  Result := Pos(spar, InText);
end;

function GetParanthEnd(parastart: integer; InText: string; FindOnEmpty: boolean; p1type, p2type: char): integer;
var
  spar, epar, cr: char;
  I, P, PS, PE, prstarts: Integer;
begin
  { The FindOnEmpty property find the first found
  start parantheses in case that its missing! }

  // Parantheses Type
  spar := p1type;
  epar := p2type;

  // Find Para
    if FindOnEmpty and (InText[parastart] <> spar) then
      for I := parastart to length( InText ) do
        if InText[I] = spar then
          begin
            parastart := I;
            Break;
          end;

  // Values Reset
  Result := 0;
  prstarts := 0;

  // Start Position
  P := parastart;

  repeat
    // Find position of "(" and ")"
    PS := Pos(spar, InText, P + 1);
    PE := Pos(epar, InText, P + 1);

    // Find which is closer
    if (PS < PE) and (PS <> 0) then
      P := PS
    else
      P := PE;

    // Avoid invalid memory access
    if P = 0 then
      Break;

    cr := InText[P];

    // Increate the amount of unfinished brackets
    if cr = spar then
        inc(prstarts);

    // Check for end bracked
      if cr = epar then
        begin
          if prstarts > 0 then
            dec(prstarts)
          else
            begin
              Result := P;

              Break;
            end;

        end;

  until (PE = 0);
end;

function SolveStringEcuation(Ecuation: string): real;
var
  I, J, C, S, T, E, L, PType: integer;
  tmp: string;
  fn1, fn2: boolean;
  n1, n2, re: real;
  CA: char;
begin
  try
    Result := stringtofloat(Ecuation);
    Exit;
  except end;

  Ecuation := Ecuation.Replace(' ', '');

  // For Global 🌎
  if GetLocalePeriod = '.' then
    Ecuation := StringReplace(Ecuation, ',', '', [rfReplaceAll])
  else
    Ecuation := StringReplace(Ecuation, '.', '', [rfReplaceAll]);

  // Paranthases count
  C := StrCount('(', Ecuation);

  // Solve paranthases
  E := Length(ecuation);
  for I := C downto 1 do
    begin
      S := StrPos('(', Ecuation, I);

      // Check Multiply (ex: 5(4-2), where it should be 5*(4-2))
      if S > 1 then
        begin
          CA := Ecuation[S-1];

          if TArrayUtils<char>.Contains(CA, num_content) then
            begin
              Ecuation := StrInsert(Ecuation, S, '*');

              S := S + 1;
            end;
        end;

      // Check for math functions
      PType := 0;
      L := 0;

      tmp := '';
      for J := S - 1 downto S - 1 - 5{const max length} do
        begin
          tmp := Ecuation[J] + tmp;

          if tmp = 'sin' then
            begin
              PType := 1;
              L := 3;
            end;
          if tmp = 'cos' then
            begin
              PType := 2;
              L := 3;
            end;
          if tmp = 'tan' then
            begin
              PType := 3;
              L := 3;
            end;
          if tmp = 'cotan' then
            begin
              PType := 4;
              L := 5;
            end;
          if tmp = 'lg' then
            begin
              PType := 5;
              L := 2;
            end;
          if tmp = 'ln' then
            begin
              PType := 6;
              L := 2;
            end;
          if tmp = 'sqrt' then
            begin
              PType := 7;
              L := 4;
            end;
          if tmp = '√' then
            begin
              PType := 7;
              L := 1;
            end;
          if tmp = 'cbrt' then
            begin
              PType := 8;
              L := 4;
            end;
          if tmp = '∛' then
            begin
              PType := 8;
              L := 1;
            end;
          if tmp = 'trunc' then
            begin
              PType := 9;
              L := 5;
            end;
          if tmp = 'round' then
            begin
              PType := 10;
              L := 5;
            end;
          if tmp = 'pow' then
            begin
              PType := 11;
              L := 3;
            end;


          if PType <> 0 then
            Break;
        end;


      // Solve parantheses
      if S < E then
        begin
          E := GetParanthEnd(S, Ecuation, false);

          tmp := StrCopy(Ecuation, S, E, true);

          // Calculate with recursion
          re := SolveStringEcuation(tmp);

          // Math Functions
          case Ptype of
            1: re := Sin( DegToRad( re ) );
            2: re := Cos( DegToRad( re ) );
            3: re := Tan( DegToRad( re ) );
            4: re := CoTan( DegToRad( re ) );
            5: re := ln( re ) / ln( 10 );
            6: re := ln( re );
            7: re := sqrt( re );
            8: re := exp(1/3*ln(re));
            9: re := trunc( re );
            10: re := round( re );
            11: re := power( re, 2 );
          end;

          // Write String
          Ecuation := StrCopy(Ecuation, 0, S - 1 - L)
           + floattostr( re )
           + StrCopy(Ecuation, E + 1, Length(Ecuation));
        end;

    end;

  // Ecuation detection
  repeat
    // Operation type
    T := 0;
    C:= Pos('*', Ecuation, 2);
    if c <> 0 then
      T := 1;
    if C = 0 then
      begin
        C:= Pos('/', Ecuation, 2);
        T := 2;
      end;
    if C = 0 then
      begin
        C:= Pos('+', Ecuation, 2);
        T := 3;
      end;
    if C = 0 then
      begin
        C:= Pos('-', Ecuation, 2);
        T := 4;
      end;

    // Exit on needede
    if T = 0  then
      Break;

    fn1 := false;
    fn2 := false;

    n1 := 0;
    n2 := 0;
    S := 0;

    // Get first number
    for I := C - 1 downto 1 do
        begin
          CA := Ecuation[I];

          if TArrayUtils<char>.Contains(CA, num_content) or ((I = 1) and (CA = '-')) then
            begin
              S := I;

              try
                n1 := StringToFloat( StrCopy(Ecuation, I, C - 1, false) );
              except
                // This Try Except statement is for ignoring error such as converting "7," when the values aftet the "," have not been read
              end;
              
              fn1 := true;
            end
              else
                if fn1 then
                  Break;
        end;

    // Get second number
    for I := C + 1 to Length(Ecuation) do
        begin
          CA := Ecuation[I];

          if TArrayUtils<char>.Contains(CA, num_content) then
            begin
              E := I;

              try
                n2 := StringToFloat( StrCopy(Ecuation, C + 1, I, false) );
              except
                // This Try Except statement is for ignoring error such as converting "7," when the values aftet the "," have not been read
              end;
              
              fn2 := true;
            end
              else
                if fn2 then
                  Break;
        end;

    // Replace eq
    if fn1 and fn2 then
      begin
        case T of
          1: tmp := floattostr(n1 * n2);
          2: tmp := floattostr(n1 / n2);
          3: tmp := floattostr(n1 + n2);
          4: tmp := floattostr(n1 - n2);
        end;

        Ecuation := StrReplZone(Ecuation, S, E, tmp);
      end
    else
      Break;
  until (C = 0);


  Result := StringToFloat(Ecuation);
end;

end.