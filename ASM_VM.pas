program ASM_VM;

const
  CR     = ^M;
  LF     = ^J;
  Tab    = ^I;
  DATMAX =  7;
  MEMMAX = 128-1;
  
Var
  ChIn  : Char;
  Token : string[3];
  IP    : byte    = 0;
  OLD_IP: byte    = 0;
  MEM   : array[0..MEMMAX] of byte;
  ACCU  : byte    = 0;
  Cycle : integer = 0; 
  
  DAT_counter: integer = 0;
  SET_Ip: boolean = false;    // this sets the IP if KeyWord is not DAT 
  running : boolean = false;  // CPU start-stop

Procedure error(s: string);
begin
  writeln(s);
end;

function SStrToInt(const s: string): Integer;
var
  i: Integer;
  subt: Integer;
  c: Char;
  charval: Integer;
begin
  subt := 0;
  for i := 1 to Length(s) do 
  begin
    c := s[i];
    charval := Ord(c) - 48;
    subt := subt * 10;
    subt := subt + charval;
  end;
  SStrToInt := subt;
end;

function HexB(b : byte): string;
const
  Hex: array[0..$F] of char = '0123456789ABCDEF';
begin
  HexB[0] := #2;
  HexB[1] := Hex[b shr 4];
  HexB[2] := Hex[b and $F];
end;

Procedure GetC;
begin
  Read(ChIn);
end;

function Alpha(c : char) : boolean;   
begin
  Alpha := UpCase(c) in ['A' .. 'Z'];
end;

function Digit(c : char) : boolean;     
begin
  Digit := c in ['0' .. '9'];
end;

function AlNum(c : char) : boolean;     
begin
  AlNum := Alpha(c) or Digit(c);
end;


function White(c : char) : boolean;    
begin
  White := c in [' ', TAB];
end;

procedure SkipWhite;                   
begin
  while White(ChIn) do GetC;
end;

function GetKeyWord : string;           
var  kw : string[3];
begin
  if not Alpha(ChIn) then Error(' -- Error In KeyWord');
  kw := '';
  while AlNum(ChIn) do
  begin
    kw := kw + UpCase(ChIn);
    GetC;
  end;
  GetKeyWord := kw;
end;

function GetNum : string;              
var  num : string[3];
begin
  num := '';
  if not Digit(ChIn) then  Error(' -- Error: Not Integer!');
  while Digit(ChIn) do
  begin
    num := num + ChIn;
    GetC;
  end;
  GetNum := num;
end;

function Scan : string;             
begin  
  if Alpha(ChIn) then Scan := GetKeyWord
  else
  if Digit(ChIn) then Scan := GetNum
  else
  begin
    Scan := ChIn;
    GetC;
  end;
  SkipWhite;
  if scan = 'DAT' then inc(DAT_counter);
  if (length(Scan) = 3) and (Scan <> 'DAT') then SET_Ip:= true;  
end;

procedure DrawScreen;
var
 i, j: byte;
 s: string;
begin
  writeln(' *  00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F');
  writeln();
  j:= 0;  
  s:= hexb(0)+'  ';
  for i:= 0 to MEMMAX do
  begin
  s:= s+hexb(MEM[i])+' ';  inc(j);
    if j = 16 then 
    begin 
    writeln(s); 
    j:=0; 
    s:=hexb(i+1 mod 16)+'  ';  
    end;
  end;
  writeln('                                                 ^-< Outport');
  writeln('    ACCU: ',hexb(ACCU),'  IP: ',hexb(OLD_IP),'  Instr: ',hexb(MEM[OLD_IP]),'   <- (all in hex!)');
  writeln('---------------------------------------------------| ',Cycle+1);
end;

procedure MemLoad(T: string);
begin
    case Upcase(T) of
    'SUB':     begin    MEM[IP]:= $AA; inc(IP);   end;  // AA
    'ADD':     begin    MEM[IP]:= $AD; inc(IP);   end;  // AD
    'CMP':     begin    MEM[IP]:= $CC; inc(IP);   end;  // CC
    'OUT':     begin    MEM[IP]:= $DD; inc(IP);   end;  // DD
    'JMP':     begin    MEM[IP]:= $EA; inc(IP);   end;  // EA
    'JIZ':     begin    MEM[IP]:= $E0; inc(IP);   end;  // E0
    'LDA':     begin    MEM[IP]:= $A0; inc(IP);   end;  // A0
    'STA':     begin    MEM[IP]:= $A1; inc(IP);   end;  // A1
    'DAT':     begin    SET_Ip := false;        end;  
  end; {case}
end;

procedure CPU;
var TMP: byte;
begin
 OLD_IP := IP; 
 Case MEM[IP] of
 $00: {HLT} begin running := false; end;
 $AA: {SUB} begin TMP:= MEM[IP+1]; ACCU := byte(ACCU-TMP); inc(IP,2); end;
 $AD: {ADD} begin TMP:= MEM[IP+1]; ACCU := byte(ACCU+TMP); inc(IP,2); end;
 $CC: {CMP} begin TMP:= MEM[IP+1]; if ACCU = MEM[TMP] then ACCU := 0; inc(IP,2); end;
 $DD: {OUT} begin TMP:= MEM[IP+1]; MEM[MEMMAX] := MEM[TMP]; inc(IP,2); end;
 $EA: {JMP} begin TMP:= MEM[IP+1]; IP := TMP; end;
 $E0: {JIZ} begin if ACCU = 0 then begin TMP:= MEM[IP+1]; IP:= TMP; end else inc(IP,2); end;
 $A0: {LDA} begin ACCU := MEM[IP+1]; inc(IP,2); end;
 $A1: {STA} begin TMP:= MEM[IP+1]; MEM[TMP] := ACCU; inc(IP,2); end;
 else  begin write('Unknown instruction:: ',MEM[IP]); running:= false; end; // else
 end; // case
   DrawScreen;
   if Cycle < 1999 then Inc(Cycle) else Running := false;
end;

procedure Execute; 
begin
IP:= 16; 
running:= true;
while running do CPU;
end;

// ==== Main ====
begin
  GetC;
  repeat
    repeat
      Token := Scan;      
      if (token <> CR) and (token <> LF) and (token <> ';') then
      begin
        if Alpha(token[1]) then
        begin
          if (Set_IP = true) and (IP <=16) then IP := 16;
          if IP < 77 then MemLoad(Token)
          else error('program too big to fit in memory!');
        end        
        else        
        if digit(token[1]) then
        begin
            MEM[IP]:= SStrToInt(token);
            inc(IP);
            inc(DAT_counter);
        end  // if digit
        else Error('Unknown token ..'); 
      end;   // if token      
    until Token = CR;                 // Carriage Return
  until EOF;                          // End Of File
  
  Execute;  // Let's Go!
end.

