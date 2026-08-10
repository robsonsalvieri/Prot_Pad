unit UBase64;

interface

uses SysUtils;

{.DEFINE SpeedDecode}
{$IFNDEF SpeedDecode}
  {$DEFINE ValidityCheck}
{$ENDIF}

function Base64Encode(const InText: AnsiString): AnsiString; overload;
function Base64Decode(const InText: AnsiString): AnsiString; overload;
function CalcEncodedSize(InSize: Cardinal): Cardinal;
function CalcDecodedSize(const InBuffer; InSize: Cardinal): Cardinal;
procedure Base64Encode(const InBuffer; InSize: Cardinal; var OutBuffer); overload; register;
{$IFDEF SpeedDecode}
	procedure Base64Decode(const InBuffer; InSize: Cardinal; var OutBuffer); overload; register;
{$ENDIF}
{$IFDEF ValidityCheck}
	function Base64Decode(const InBuffer; InSize: Cardinal; var OutBuffer): Boolean; overload; register;
{$ENDIF}
procedure Base64Encode(const InText: PAnsiChar; var OutText: PAnsiChar); overload;
procedure Base64Decode(const InText: PAnsiChar; var OutText: PAnsiChar); overload;
procedure Base64Encode(const InText: AnsiString; var OutText: AnsiString); overload;
procedure Base64Decode(const InText: AnsiString; var OutText: AnsiString); overload;

implementation

const
  cBase64Codec: array[0..63] of AnsiChar = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  Base64Filler = '=';

function Base64Encode(const InText: string): string; overload;
var
  vRetorno: AnsiString;
begin
Base64Encode(AnsiString(InText), vRetorno);
Result := vRetorno;
end;

function Base64Decode(const InText: string): string; overload;
var
  vRetorno: AnsiString;
begin
Base64Decode(AnsiString(InText), vRetorno);
Result := vRetorno;
end;

function CalcEncodedSize(InSize: Cardinal): Cardinal;
begin
Result:=(InSize div 3) shl 2;
if ((InSize mod 3) > 0) then
	Inc(Result, 4);
end;

function CalcDecodedSize(const InBuffer; InSize: Cardinal): Cardinal;
type
	BA = array of Byte;
begin
Result:=0;
if InSize = 0 then
	Exit;
if InSize mod 4 <> 0 then
	Exit;
Result:=InSize div 4 * 3;
if (BA(InBuffer)[InSize - 2] = Ord(Base64Filler)) then
	Dec(Result, 2)
else
	if BA(InBuffer)[InSize - 1] = Ord(Base64Filler) then
		Dec(Result);
end;

procedure Base64Encode(const InBuffer; InSize: Cardinal; var OutBuffer); register;
var
	ByThrees, LeftOver: Cardinal;
asm
mov  ESI, [EAX]
mov  EDI, [ECX]
mov  EAX, EBX
mov  ECX, $03
xor  EDX, EDX
div  ECX
mov  ByThrees, EAX
mov  LeftOver, EDX
lea  ECX, cBase64Codec[0]
xor  EAX, EAX
xor  EBX, EBX
xor  EDX, EDX
cmp  ByThrees, 0
jz   @@LeftOver
@@LoopStart:
	LODSW
	mov  BL, AL
	shr  BL, 2
	mov  DL, BYTE PTR [ECX + EBX]
	mov  BH, AH
	and  BH, $0F
	rol  AX, 4
	and  AX, $3F
	mov  DH, BYTE PTR [ECX + EAX]
	mov  AX, DX
	STOSW
	LODSB
	mov  BL, AL
	shr  BX, 6
	mov  DL, BYTE PTR [ECX + EBX]
	and  AL, $3F
	xor  AH, AH
	mov  DH, BYTE PTR [ECX + EAX]
	mov  AX, DX
	STOSW
dec  ByThrees
jnz  @@LoopStart
@@LeftOver:
	cmp  LeftOver, 0
	jz   @@Done
	xor  EAX, EAX
	xor  EBX, EBX
	xor  EDX, EDX
	LODSB
	shl  AX, 6
	mov  BL, AH
	mov  DL, BYTE PTR [ECX + EBX]
	dec  LeftOver
	jz   @@SaveOne
	shl  AX, 2
	and  AH, $03
	LODSB
	shl  AX, 4
	mov  BL, AH
	mov  DH, BYTE PTR [ECX + EBX]
	shl  EDX, 16
	shr  AL, 2
	mov  BL, AL
	mov  DL, BYTE PTR [ECX + EBX]
	mov  DH, Base64Filler
	jmp  @@WriteLast4
@@SaveOne:
	shr  AL, 2
	mov  BL, AL
	mov  DH, BYTE PTR [ECX + EBX]
	shl  EDX, 16
	mov  DH, Base64Filler
	mov  DL, Base64Filler
@@WriteLast4:
	mov  EAX, EDX
	ror EAX, 16
	STOSD
@@Done:
end;

{$IFDEF SpeedDecode}
procedure Base64Decode(const InBuffer; InSize: Cardinal; var OutBuffer); overload; register;
{$ENDIF}
{$IFDEF ValidityCheck}
function Base64Decode(const InBuffer; InSize: Cardinal; var OutBuffer): Boolean; overload; register;
{$ENDIF}
const
{$IFDEF SpeedDecode}
cBase64Codec: array[0..127] of Byte =
{$ENDIF}
{$IFDEF ValidityCheck}
cBase64Codec: array[0..255] of Byte =
{$ENDIF}
  (
	$FF, $FF, $FF, $FF, $FF, {005>} $FF, $FF, $FF, $FF, $FF, // 000..009
	$FF, $FF, $FF, $FF, $FF, {015>} $FF, $FF, $FF, $FF, $FF, // 010..019
	$FF, $FF, $FF, $FF, $FF, {025>} $FF, $FF, $FF, $FF, $FF, // 020..029
	$FF, $FF, $FF, $FF, $FF, {035>} $FF, $FF, $FF, $FF, $FF, // 030..039
	$FF, $FF, $FF, $3E, $FF, {045>} $FF, $FF, $3F, $34, $35, // 040..049
	$36, $37, $38, $39, $3A, {055>} $3B, $3C, $3D, $FF, $FF, // 050..059
	$FF, $FF, $FF, $FF, $FF, {065>} $00, $01, $02, $03, $04, // 060..069
	$05, $06, $07, $08, $09, {075>} $0A, $0B, $0C, $0D, $0E, // 070..079
	$0F, $10, $11, $12, $13, {085>} $14, $15, $16, $17, $18, // 080..089
	$19, $FF, $FF, $FF, $FF, {095>} $FF, $FF, $1A, $1B, $1C, // 090..099
	$1D, $1E, $1F, $20, $21, {105>} $22, $23, $24, $25, $26, // 100..109
	$27, $28, $29, $2A, $2B, {115>} $2C, $2D, $2E, $2F, $30, // 110..119
	$31, $32, $33, $FF, $FF, {125>} $FF, $FF, $FF			// 120..127
	{$IFDEF ValidityCheck}
							   {125>}			  , $FF, $FF, // 128..129
	  $FF, $FF, $FF, $FF, $FF, {135>} $FF, $FF, $FF, $FF, $FF, // 130..139
	  $FF, $FF, $FF, $FF, $FF, {145>} $FF, $FF, $FF, $FF, $FF, // 140..149
	  $FF, $FF, $FF, $FF, $FF, {155>} $FF, $FF, $FF, $FF, $FF, // 150..159
	  $FF, $FF, $FF, $FF, $FF, {165>} $FF, $FF, $FF, $FF, $FF, // 160..169
	  $FF, $FF, $FF, $FF, $FF, {175>} $FF, $FF, $FF, $FF, $FF, // 170..179
	  $FF, $FF, $FF, $FF, $FF, {185>} $FF, $FF, $FF, $FF, $FF, // 180..189
	  $FF, $FF, $FF, $FF, $FF, {195>} $FF, $FF, $FF, $FF, $FF, // 190..199
	  $FF, $FF, $FF, $FF, $FF, {205>} $FF, $FF, $FF, $FF, $FF, // 200..209
	  $FF, $FF, $FF, $FF, $FF, {215>} $FF, $FF, $FF, $FF, $FF, // 210..219
	  $FF, $FF, $FF, $FF, $FF, {225>} $FF, $FF, $FF, $FF, $FF, // 220..229
	  $FF, $FF, $FF, $FF, $FF, {235>} $FF, $FF, $FF, $FF, $FF, // 230..239
	  $FF, $FF, $FF, $FF, $FF, {245>} $FF, $FF, $FF, $FF, $FF, // 240..249
	  $FF, $FF, $FF, $FF, $FF, {255>} $FF					  // 250..255
	{$ENDIF}
  );
asm
push EBX
mov  ESI, [EAX]
mov  EDI, [ECX]
{$IFDEF ValidityCheck}
	mov  EAX, InSize
	and  EAX, $03
	cmp  EAX, $00
	jz   @@DecodeStart
	jmp  @@ErrorDone
	@@DecodeStart:
{$ENDIF}
mov  EAX, InSize
shr  EAX, 2
jz   @@Done
lea  ECX, cBase64Codec[0]
xor  EBX, EBX
dec  EAX
jz   @@LeftOver
push EBP
mov  EBP, EAX
@@LoopStart:
	LODSD
	mov  EDX, EAX
	mov  BL, DL
	mov  AH, BYTE PTR [ECX + EBX]
	{$IFDEF ValidityCheck}
		cmp  AH, $FF
		jz   @@ErrorDoneAndPopEBP
	{$ENDIF}
	mov  BL, DH
	mov  AL, BYTE PTR [ECX + EBX]
	{$IFDEF ValidityCheck}
		cmp  AL, $FF
		jz   @@ErrorDoneAndPopEBP
	{$ENDIF}
	shl  AL, 2
	ror  AX, 6
	STOSB
	shr  AX, 12
	shr  EDX, 16
	mov  BL, DL
	mov  AH, BYTE PTR [ECX + EBX]
	{$IFDEF ValidityCheck}
		cmp  AH, $FF
		jz   @@ErrorDoneAndPopEBP
	{$ENDIF}
	shl  AH, 2
	rol  AX, 4
	mov  BL, DH
	mov  BL, BYTE PTR [ECX + EBX]
	{$IFDEF ValidityCheck}
		cmp  BL, $FF
		jz   @@ErrorDoneAndPopEBP
	{$ENDIF}
	or   AH, BL
	STOSW
	dec  EBP
	jnz  @@LoopStart
	pop  EBP
@@LeftOver:
	LODSD
	mov  EDX, EAX
	mov  BL, DL
	mov  AH, BYTE PTR [ECX + EBX]
	{$IFDEF ValidityCheck}
		cmp  AH, $FF
		jz   @@ErrorDone
	{$ENDIF}
	mov  BL, DH
	mov  AL, BYTE PTR [ECX + EBX]
	{$IFDEF ValidityCheck}
		cmp  AL, $FF
		jz   @@ErrorDone
	{$ENDIF}
	shl  AL, 2
	ror  AX, 6
	STOSB
	shr  EDX, 16
	cmp  DL, Base64Filler
	jz   @@SuccessDone
	shr  AX, 12
	mov  BL, DL
	mov  AH, BYTE PTR [ECX + EBX]
	{$IFDEF ValidityCheck}
		cmp  AH, $FF
		jz   @@ErrorDone
	{$ENDIF}
	shl  AH, 2
	rol  AX, 4
	STOSB
	cmp  DH, Base64Filler
	jz   @@SuccessDone
	mov  BL, DH
	mov  BL, BYTE PTR [ECX + EBX]
	{$IFDEF ValidityCheck}
		cmp  BL, $FF
		jz   @@ErrorDone
	{$ENDIF}
	or   AH, BL
	mov  AL, AH
	STOSB
@@SuccessDone:
	{$IFDEF ValidityCheck}
		mov  Result, $01
		jmp  @@Done
		@@ErrorDoneAndPopEBP:
			pop  EBP
		@@ErrorDone:
			mov  Result, $00
	{$ENDIF}
@@Done:
	pop  EBX
end;

procedure Base64Encode(const InText: PAnsiChar; var OutText: PAnsiChar);
var
	InSize, OutSize: Cardinal;
begin
InSize:=Length(InText);
OutSize:=CalcEncodedSize(InSize);
OutText:=StrAlloc(Succ(OutSize));
OutText[OutSize]:=#0;
Base64Encode(InText, InSize, OutText);
end;

procedure Base64Encode(const InText: AnsiString; var OutText: AnsiString); overload;
var
	InSize, OutSize: Cardinal;
	PIn, POut: Pointer;
begin
InSize:=Length(InText);
OutSize:=CalcEncodedSize(InSize);
SetLength(OutText, OutSize);
PIn:=@InText[1];
POut:=@OutText[1];
Base64Encode(PIn, InSize, POut);
end;

procedure Base64Decode(const InText: PAnsiChar; var OutText: PAnsiChar); overload;
var
	InSize, OutSize: Cardinal;
begin
InSize:=Length(InText);
OutSize:=CalcDecodedSize(InText, InSize);
OutText:=StrAlloc(Succ(OutSize));
OutText[OutSize]:=#0;
{$IFDEF SpeedDecode}
Base64Decode(InText, InSize, OutText);
{$ENDIF}
{$IFDEF ValidityCheck}
if not Base64Decode(InText, InSize, OutText) then
	OutText[0]:=#0;
{$ENDIF}
end;

procedure Base64Decode(const InText: AnsiString; var OutText: AnsiString); overload;
var
	InSize, OutSize: Cardinal;
	PIn, POut: Pointer;
begin
InSize:=Length(InText);
PIn:=@InText[1];
OutSize:=CalcDecodedSize(PIn, InSize);
SetLength(OutText, OutSize);
FillChar(OutText[1], OutSize, '.');
POut:=@OutText[1];
{$IFDEF SpeedDecode}
Base64Decode(PIn, InSize, POut);
{$ENDIF}
{$IFDEF ValidityCheck}
if not Base64Decode(PIn, InSize, POut) then
	SetLength(OutText, 0);
{$ENDIF}
end;

end.
 