unit LojxFun;

interface

Uses Vcl.Dialogs, System.SysUtils, Winapi.Windows, Vcl.Forms, Vcl.ExtCtrls,
     Vcl.StdCtrls, Vcl.Controls, Winapi.Messages, System.Classes,
     Vcl.Graphics, System.IniFiles, Vcl.FileCtrl, System.Math,
     System.AnsiStrings;


const
  BufferSize  = 1024;

type TaString = array of AnsiString;

  Function Replicate( sTexto:AnsiString; iVezes:Integer ):AnsiString;
  Function FormataTexto( sValor:AnsiString; iTamanho, iDecimais, iTipo:Integer; Separador:AnsiString = ','  ) : AnsiString;
  Function FormataData( dData:TDateTime; iTipo:Integer ):AnsiString;
  Function StrTran( sTexto, sOrigem, sDestino:AnsiString):AnsiString;
  Function DecToBin( iDec:Integer ):AnsiString;
  Function MesExtenso( iMes:Integer ):AnsiString;
  Function Space( iTamanho:Integer ): AnsiString;
  Procedure MontaArray( sTexto:AnsiString; var aFormas:TaString);
  Function AscToHex( sAsc:AnsiString ):AnsiString;
  Procedure MsgLoja ( Msg:AnsiString=''; Tempo:Integer=0 );
  Procedure LjMsgDlg( sTexto:AnsiString );
  Procedure WriteLog ( Arquivo,Texto:AnsiString );
  Procedure WriteLog2( Arquivo,Texto:AnsiString );
  Function LimpaAcentuacao( sTexto:AnsiString ):AnsiString;
  Procedure SaveToFile(Arquivo:AnsiString; Comandos:TStringList);
  Function Right( sTexto:AnsiString;nQuant:Integer ):AnsiString;
  Procedure MsgStop( Texto:AnsiString );
  Function HexToBin(HexNr : AnsiString): AnsiString; { only stringsize is limit of binnr }
  Function HexCharToBin(HexToken : AnsiChar): AnsiString;
  Function HexCharToInt(HexToken : AnsiChar):Integer;
  Function SigaLojaINI( sNomeArq,sGrupo,sTipo,sInicPad:AnsiString ) : AnsiString;
  Function Hex2Dec( cVal:AnsiString): AnsiString;
  Function LogDLL : Boolean;
  Function LeArqRetorno(sPath, sArquivo: AnsiString; iPosIni, iQtdCarac: Integer ) : AnsiString;
  Function LeArqIni(sPath, sArquivo, sSecao, sCampo, sDefault: AnsiString ) : AnsiString;
  Function CopRenArquivo(sPathOld, sArqOld, sPathNew, sArqNew: AnsiString ) : AnsiString;
  Function ExisteDir(sDiretorio : AnsiString) : Boolean;
  Procedure GravaLog( sTexto:AnsiString );
  Procedure GravaLogEmulNFisc( sTexto:AnsiString );
  Function GetDataHoraArq(sArquivo: AnsiString): AnsiString;
  Function GetVersao(sArquivo: AnsiString): AnsiString;
  function Arredondar(Valor: Double; Dec: Integer): Double;
  function SubstituiStr (Variavel ,Localizar ,Substituir : AnsiString) : AnsiString;
  Function ContaChar(cTexto, cChar : AnsiString): Integer;
  function RemoveTags ( Mensagem : AnsiString ) : AnsiString;
  Function LimpaDir(cPath,cFile,cExtensao : AnsiString): Boolean;
  Function ClearLog(): Boolean;
  Procedure GrvTempRedZ( aValor: Array of AnsiString);
  Function GetTempRedZ( sDataMovimento: AnsiString ) : TaString;
  Function ArredCV0909( xValor: Real ) : Currency;
  Function CopiarArquivo( Const sourcefilename, targetfilename: AnsiString ): Boolean;

implementation
var
  fmMsg : TForm;
  pnFundo : TPanel;
  laMsg : TLabel;

//----------------------------------------------------------------------------
function FormataTexto( sValor:AnsiString; iTamanho, iDecimais,
                     iTipo:Integer; Separador:AnsiString = ',' ) : AnsiString;
begin
// Formata o retorno do texto (com zeros a esquerda)
// 1-  com separador de decimais e zeros a esquerda.       Ex.:   00999,99
// 2-  sem separador de decimais e zeros a esquerda.       Ex.:    0099999
// 3-  com separador de decimais e espacos a esquerda.     Ex.:  '  999,99'
// 4-  sem separador de decimais e espacos a esquerda.     Ex.:  '   99999'
// 5-  com separador de decimais e sem espacos a esquerda. Ex.:    '999,99'

sValor := StrTran(sValor,',','.');
sValor := FloatToStrf(StrToFloat(sValor),ffFixed,18,iDecimais);

If (iTipo = 2) or (iTipo = 4)
then sValor := StrTran(sValor,'.','');

If (iTipo = 1) or (iTipo = 2) then
begin
  while (Length(sValor)<iTamanho) do
    sValor := '0' + sValor;
end
else If iTipo <> 5 then
begin
  while (Length(sValor)<iTamanho) do
    sValor := ' ' + sValor;
end;

If Pos('-',sValor) > 0
Then sValor := '-' + Copy(sValor,1,(Pos('-',sValor)-1)) + Copy(sValor,(Pos('-',sValor)+1),Length(sValor));

Result := sValor;

end;

//----------------------------------------------------------------------------
function FormataData( dData:TDateTime; iTipo:Integer ):AnsiString;
var
  sData : AnsiString;
begin
// formata data cf. tipo selecionado
// 1- DDMMAA
// 2- DDMMAAAA
// 3- DD/MM/AA
// 4- DD/MM/AAAA
// 5- AAAAMMDD
// 6- AAMMDD

sData := FormatDateTime('dd/mm/yyyy', dData);
if iTipo = 1 then
  result := copy(sData,1,2)+copy(sData,4,2)+copy(sData,9,2)
else if iTipo = 2 then
  result := StrTran(sData, '/', '')
else if iTipo = 3 then
  result := copy(sData,1,6)+copy(sData,9,2)
else if iTipo = 4 then
  result := sData
else if iTipo = 5 then
  result := copy(sData,7,4) + copy(sData,4,2) + copy(sData,1,2)
else if iTipo = 6 then
  result := copy(sData,9,2)+copy(sData,4,2)+copy(sData,1,2)
else
  result := sData;
end;


//----------------------------------------------------------------------------
function Replicate( sTexto:AnsiString; iVezes:Integer ):AnsiString;
begin
  while Length(result) < iVezes do
    result := result + sTexto;
end;

//----------------------------------------------------------------------------
function StrTran( sTexto, sOrigem, sDestino:AnsiString):AnsiString;
var
   sRet: AnsiString;
   nPos: Integer;
begin
   sRet := sTexto;
   //Verifica se possui AnsiString para substituir
   nPos := Pos (sOrigem, sRet);
   while nPos <> 0 do
   begin
      //Exclui texto que sera substituido
      Delete(sRet, nPos, Length (sOrigem));
      //Insere novo texto
      Insert(sDestino, sRet , nPos);
      //Verifica se possui mais AnsiString para substituir
      nPos := Pos (sOrigem, sRet);
   end;

Result := sRet;
end;

//----------------------------------------------------------------------------
function DecToBin( iDec:Integer ):AnsiString;
var
  iDividendo : Integer;
  sRet : AnsiString;
begin
  sRet := '';
  iDividendo := iDec;
  while iDividendo >= 2 do
  begin
    sRet := IntToStr(iDividendo mod 2) + sRet;
    iDividendo := iDividendo div 2;
  end;
  sRet := IntToStr(iDividendo) + sRet;
  if Length(sRet) < 8 then
    sRet := Replicate('0', 8-Length(sRet)) + sRet;

  result := sRet;
end;

//----------------------------------------------------------------------------
function MesExtenso( iMes:Integer ):AnsiString;
var
  aMes : array[1..12] of AnsiString;
begin
  aMes[1] := 'Janeiro';
  aMes[2] := 'Fevereiro';
  aMes[3] := 'Marco';
  aMes[4] := 'Abril';
  aMes[5] := 'Maio';
  aMes[6] := 'Junho';
  aMes[7] := 'Julho';
  aMes[8] := 'Agosto';
  aMes[9] := 'Setembro';
  aMes[10] := 'Outubro';
  aMes[11] := 'Novembro';
  aMes[12] := 'Dezembro';

  if iMes in [1..12] then
    Result := aMes[iMes]
  else
    Result := '';
end;

//----------------------------------------------------------------------------
function Space( iTamanho:Integer ): AnsiString;
begin
  result := '';
  while Length(result) < iTamanho do
    result := result + ' ';
end;

//----------------------------------------------------------------------------
procedure MontaArray( sTexto:AnsiString; var aFormas:TaString );
var
  iTamanho : Integer;
  iPos : Integer;
  sFormas : AnsiString;
begin
  if Copy(sTexto,1,1) = '|' then
    sTexto := Copy(sTexto,2,Length(sTexto));

  iTamanho := 0;
  While (Pos('|', sTexto) > 0) do
  begin
    Inc(iTamanho);
    SetLength( aFormas, iTamanho );
    iPos := Pos('|', sTexto);
    if iPos = 1 then
      sFormas := ''
    else
      sFormas := Copy(sTexto, 1, iPos-1);
    aFormas[iTamanho-1] := sFormas ;
    sTexto := Copy(sTexto, iPos+1, Length(sTexto));
  end;

  if Length(sTexto)>0 then
  begin
    Inc(iTamanho);
    SetLength( aFormas, iTamanho );
    aFormas[iTamanho-1] := sTexto;
  end;
end;

//----------------------------------------------------------------------------
function AscToHex( sAsc:AnsiString ):AnsiString;
var
  iPos, iVal1, iVal2 : Integer;
  sHex, sByte1, sByte2 : AnsiString;
begin
sHex := '';
For iPos := 1 to Length(sAsc) do
begin
  iVal1 := Ord(sAsc[iPos]) div 16;
  iVal2 := Ord(sAsc[iPos]) mod 16;

  if iVal1 > 9 then
          sByte1 := Chr(55+iVal1)
  else
          sByte1 := IntToStr(iVal1);
  if iVal2 > 9 then
          sByte2 := Chr(55+iVal2)
  else
          sByte2 := IntToStr(iVal2);
  sHex := sHex + sByte1 + sByte2;
end;

Result := sHex;
end;

procedure WriteLog2(Arquivo,Texto:AnsiString );
var
  Lista : TStringList;
begin
  Lista := TStringList.Create();
  Lista.Clear;

  if FileExists(Arquivo) = False
  then Lista.SaveToFile(Arquivo);

  Lista.LoadFromFile(Arquivo);
  Lista.Add(Texto);
  Lista.SaveToFile(Arquivo);
end;

//----------------------------------------------------------------------------
procedure WriteLog(Arquivo,Texto:AnsiString );
// Foram utilizadas as funções da API do Windows, para forçar a gravação
// dos arquivos caso ocorra queda de energia.
// CreateFile, SetFilePointer, WriteFile, SetEndOfFile, FlushFileBuffers e
// CloseHandle.
var
  pFile, pBuffer : PChar;
  hFile : Int64;
  nTam, nWritten : LongWord;
  sData : AnsiString;
begin
  sData := DateTimeToStr( Now() );
//  pFile := System.SysUtils.StrAlloc(Length(AnsiString(Arquivo))+ 1);
//  System.AnsiStrings.StrPCopy(@pFile, AnsiString(Arquivo) );
  pFile := PChar(Arquivo);
  hFile := CreateFile( pFile,
                       GENERIC_WRITE+GENERIC_READ,
                       0,                                     // Exclusive
                       Nil,
                       OPEN_ALWAYS,
                       FILE_FLAG_WRITE_THROUGH,
                       0 );
  if hFile <> INVALID_HANDLE_VALUE then
  begin
    nTam    := Length(pChar(Texto)) + 3;
    pBuffer := PChar( Texto  + Chr(13) + Chr(10) );
    SetFilePointer( hFile,
                    0,
                    Nil,
                    FILE_END );
    WriteFile( hFile,
               pBuffer^,
               nTam,
               nWritten,
               Nil);
    SetEndOfFile( hFile );
    FlushFileBuffers( hFile );
    CloseHandle( hFile );
  end;
//  System.SysUtils.StrDispose(pFile);
end;

//------------------------------------------------------------------------------
procedure MsgLoja ( Msg:AnsiString=''; Tempo:Integer=0 );
var
  nTime : Integer;
begin
  if Msg <> '' then
  begin
    // Configuracao do form
    fmMsg := TForm.Create(Nil);
    with fmMsg do
    begin
     BorderStyle := bsNone;
      Width       := 384;
      Height      := 70;
      Position    := poScreenCenter;
      Visible     := False;
      FormStyle   := fsStayOnTop;
    end;

    // Configuração do panel
    pnFundo := TPanel.Create(fmMsg);
    with pnFundo do
    begin
      Parent     := fmMsg;
      Visible    := True;
      Align      := alClient;
      BevelInner := bvLowered;
      BevelOuter := bvRaised;
    end;

    // Configuracao da mensagem
    laMsg := TLabel.Create(pnFundo);
    with laMsg do
    begin
      Parent    := pnFundo;
      Visible   := True;
      Align     := alNone;
      Alignment := taCenter;
      Layout    := tlCenter;
      Caption   := Msg;
      Top       := 20;
      Left      := 25;
      Width     := 350;
      Height    := 30;
      AutoSize  := False;
    end;

    fmMsg.Show;
    Application.ProcessMessages;

    if Tempo <> 0 then
    begin
      nTime := 0;
      while nTime < Tempo do
      begin
        nTime := nTime + 100;
        Sleep(100);
        Application.ProcessMessages;
      end;
      fmMsg.Release;
    end;
  end
  else
  begin
    fmMsg.Release;
  end;
end;

//----------------------------------------------------------------------------
function LimpaAcentuacao( sTexto:AnsiString ):AnsiString;
var
  i : Integer;
  aCarac01,aCarac02 : array[0..23] of AnsiString;
begin
  aCarac01[0] := 'á'  ; aCarac02[0] := 'a';
  aCarac01[1] := 'ã'  ; aCarac02[1] := 'a';
  aCarac01[2] := 'â'  ; aCarac02[2] := 'a';
  aCarac01[3] := 'ä'  ; aCarac02[3] := 'a';
  aCarac01[4] := 'é'  ; aCarac02[4] := 'e';
  aCarac01[5] := 'ê'  ; aCarac02[5] := 'e';
  aCarac01[6] := 'é'  ; aCarac02[6] := 'e';
  aCarac01[7] := 'ë'  ; aCarac02[7] := 'e';
  aCarac01[8] := 'í'  ; aCarac02[8] := 'i';
  aCarac01[9] := 'ó'  ; aCarac02[9] := 'o';
  aCarac01[10] := 'õ' ; aCarac02[10] := 'o';
  aCarac01[11] := 'ó' ; aCarac02[11] := 'o';
  aCarac01[12] := 'ô' ; aCarac02[12] := 'o';
  aCarac01[13] := 'ö' ; aCarac02[13] := 'o';
  aCarac01[14] := '”' ; aCarac02[14] := 'o';
  aCarac01[15] := 'ú' ; aCarac02[15] := 'u';
  aCarac01[16] := 'û' ; aCarac02[16] := 'u';
  aCarac01[17] := 'ü' ; aCarac02[17] := 'u';
  aCarac01[18] := 'ç' ; aCarac02[18] := 'c';
  aCarac01[19] := '‚' ; aCarac02[19] := 'e';
  aCarac01[20] := '¢' ; aCarac02[20] := 'o';
  aCarac01[21] := 'ˆ' ; aCarac02[21] := 'e';
  aCarac01[22] := '‡' ; aCarac02[22] := 'c';
  aCarac01[23] := ' ' ; aCarac02[23] := 'a';


  For i:=0 to Length(aCarac01) - 1 do
    sTexto := StrTran(sTexto,aCarac01[i],aCarac02[i]);
  result := sTexto;
end;

//----------------------------------------------------------------------------
procedure SaveToFile(Arquivo:AnsiString; Comandos:TStringList);
// Foram utilizadas as funções da API do Windows, para forçar a gravação
// dos arquivos caso ocorra queda de energia.
// CreateFile, SetFilePointer, WriteFile, SetEndOfFile, FlushFileBuffers e
// CloseHandle.
var
  pFile, pBuffer : PChar;
  hFile : Int64;
  i : Integer;
  nTam, nWritten : LongWord;
begin
  pFile := StrAlloc(Length(Arquivo)+1);
  System.AnsiStrings.StrPCopy(@pFile, Arquivo);
  hFile := CreateFile( pFile,
                       GENERIC_WRITE+GENERIC_READ,
                       0,                                     // Exclusive
                       Nil,
                       CREATE_ALWAYS,
                       FILE_FLAG_WRITE_THROUGH,
                       0 );
  if hFile <> INVALID_HANDLE_VALUE then
  begin
    for i := 0 to Comandos.Count-1 do
    begin
      nTam := Length(Comandos.Strings[i])+2;
      pBuffer := PChar(Comandos.Strings[i]+#13+#10);
      WriteFile( hFile,
                 pBuffer^,
                 nTam,
                 nWritten,
                 Nil );
    end;
    SetEndOfFile( hFile );
    FlushFileBuffers( hFile );
    CloseHandle( hFile );
  end;
  StrDispose(pFile);
end;

//----------------------------------------------------------------------------
function Right( sTexto:AnsiString;nQuant:Integer ):AnsiString;
var
  sRet : AnsiString;
begin
  sRet := copy(sTexto,Length(sTexto)-nQuant+1,nQuant);
  Result := sRet;
end;

{==============================================================================}
{ FUNCTION  :  RESULTSTRING = HexToBin(HEXSTRING)                              }
{==============================================================================}
{ PURPOSE   : Convert a Hex number (AnsiString) to a Binary number (AnsiString)        }
{==============================================================================}
{ PRECONDITION : HEXSTRING needs to be AnsiString representation of a Hex number   }
{ POSTCONDITION: RESULTSTRING contains the binary representation of the Hex nr }
{==============================================================================}
function HexToBin(HexNr : AnsiString): AnsiString; { only stringsize is limit of binnr }
var Counter : integer;
begin
  Result:='';

  for Counter:=1 to length(HexNr) do
    Result:= Result + HexCharToBin(AnsiChar(HexNr[Counter]));
end;

{==============================================================================}
{ FUNCTION  :  RESULTSTRING = HexCharToBin(HEXCHAR)                            }
{==============================================================================}
{ PURPOSE   : Convert a Hex character (0..9 & A..F or a..f) to a binary AnsiString }
{==============================================================================}
{ PRECONDITION : HEXCHAR needs to be in the 0..9 or A...F range                }
{ POSTCONDITION: RESULTSTRING is the binary value of the HEXCHAR               }
{==============================================================================}
function HexCharToBin(HexToken : AnsiChar): AnsiString;
var DivLeft : integer;
begin
    DivLeft:=HexCharToInt(HexToken);   { first HEX->BIN }
    Result:='';
                                       { Use reverse dividing }
    repeat                             { Trick; divide by 2 }
      if odd(DivLeft) then             { result = odd ? then bit = 1 }
        Result:='1'+Result             { result = even ? then bit = 0 }
      else
        Result:='0'+Result;

      DivLeft:=DivLeft div 2;       { keep dividing till 0 left and length = 4 }
    until (DivLeft=0) and (length(Result)=4);      { 1 token = nibble = 4 bits }
end;

{==============================================================================}
{ FUNCTION  :  RESULTINTEGER = HexCharToInt(HEXCHAR)                           }
{==============================================================================}
{ PURPOSE   : Convert a Hex character (0..9 & A..F or a..f) to an integer      }
{==============================================================================}
{ PRECONDITION : HEXCHAR needs to be in the 0..9 or A...F range                }
{ POSTCONDITION: RESULTINTEGER is the integer value of the HEXCHAR             }
{==============================================================================}
function HexCharToInt(HexToken : AnsiChar):Integer;
begin
  {if HexToken>#97 then HexToken:=Chr(Ord(HexToken)-32); { use lowercase aswell }

  Result:=0;

  if (HexToken>#47) and (HexToken<#58) then       { chars 0....9 }
     Result:=Ord(HexToken)-48
  else if (HexToken>#64) and (HexToken<#71) then  { chars A....F }
     Result:=Ord(HexToken)-65 + 10;
end;

//----------------------------------------------------------------------------
procedure MsgStop( Texto:AnsiString );
begin
  MessageDlg(Texto, mtError, [mbOK], 0);
end;

//----------------------------------------------------------------------------
function SigaLojaINI( sNomeArq,sGrupo,sTipo,sInicPad:AnsiString ) : AnsiString;
var sPath:AnsiString;
    fArquivo:TIniFile;
begin
  if sNomeArq = ''
  then sNomeArq := 'SIGALOJA.INI';
  sPath := ExtractFilePath(Application.ExeName);
  fArquivo    := TIniFile.Create(sPath+'\'+sNomeArq);
  If fArquivo.ReadString(sGrupo, sTipo, '') = '' then
    fArquivo.WriteString(sGrupo, sTipo, sInicPad);
  Result := fArquivo.ReadString(sGrupo, sTipo, sInicPad);
end;


//----------------------------------------------------------------------------
procedure LjMsgDlg( sTexto:AnsiString );
begin
  MessageDlg( sTexto, mtError,[mbOK],0);
end;

//----------------------------------------------------------------------------
Function Hex2Dec(cVal:AnsiString): AnsiString;
Var cString : AnsiString;
    nVal : Integer;
Begin
cString:= '0123456789ABCDEF';

If Length(cVal) < 4 then
	cVal:= Replicate('0', 4 - Length(cVal) ) + cVal;

nVal :=        ( Pos( Copy( cVal, 1, 1 ), cString ) - 1  ) * 4096;
nVal := nVal + ( Pos( Copy( cVal, 2, 1 ), cString ) - 1  ) * 256;
nVal := nVal + ( Pos( Copy( cVal, 3, 1 ), cString ) - 1  ) * 16;
nVal := nVal + ( Pos( Copy( cVal, 4, 1 ), cString ) - 1  );

Result := IntToStr(nVal);
end;

//------------------------------------------------------------------------------
function LogDLL : Boolean;
var
  sPath : AnsiString;
  fArquivo : TIniFile;
begin
   // Pega o Path da SIGALOJA.DLL
   sPath := ExtractFilePath(Application.ExeName);
   try
      fArquivo := TIniFile.Create(sPath+'SIGALOJA.INI');
      Result := (fArquivo.ReadString('LogDLL', 'Log', '') = '1');
      fArquivo.Free;
   except
      Result := False;
   end;
end;

//------------------------------------------------------------------------------
//Usada na Bematech - ImpFiscBematechAutoNivel.Pas
Function LeArqRetorno(sPath, sArquivo: AnsiString; iPosIni, iQtdCarac: Integer ) : AnsiString;
Var
  sFile, sLinha : AnsiString;
  fArq  : TIniFile;
  fFile : TextFile;
begin
  fArq := TInifile.Create( sPath + sArquivo );
  try
    sFile := fArq.ReadString( 'Sistema', 'Path', '' )+'\' +'RETORNO.TXT';
    If FileExists(sFile) then
    begin
      AssignFile(fFile, sFile);
      Reset(fFile);
      If not Eof(fFile) then
      begin
        ReadLn(fFile, sLinha);
        Result := Trim( Copy( sLinha, iPosIni, iQtdCarac ) );
      end
    end
  except
    Result := '';
  end;
    CloseFile( fFile );
end;

//------------------------------------------------------------------------------
Function LeArqIni(sPath, sArquivo, sSecao, sCampo, sDefault: AnsiString ) : AnsiString;
Var
  fArquivo : TIniFile;
  sRetorno : AnsiString;
begin

  If not (Copy(sPath , Length(sPath), 1) = '\') then
    sPath := sPath + '\';

  try
    fArquivo := TInifile.Create( sPath + sArquivo );
    sRetorno := fArquivo.ReadString( sSecao, sCampo, sDefault );
  except
    sRetorno := sDefault;
  end;

  fArquivo.Free;
  Result := sRetorno;
end;

//------------------------------------------------------------------------------
Function CopRenArquivo(sPathOld, sArqOld, sPathNew, sArqNew: AnsiString ) : AnsiString;
Var
  sRetorno : AnsiString;
begin
  sRetorno := '0';

  If not (Copy(sPathOld , Length(sPathOld), 1) = '\')
  then sPathOld := sPathOld + '\';

  If not (Copy(sPathNew , Length(sPathNew), 1) = '\')
  then sPathNew := sPathNew + '\';

  GravaLog(' CopRenArquivo -> Caminho antigo: '+ sPathOld + sArqOld + ' / Caminho novo: ' + sPathNew + sArqNew);
  If not CopyFile( PChar( sPathOld + sArqOld ), PChar( sPathNew + sArqNew ), False ) then
  begin
    GravaLog(' CopRenArquivo -> Erro ao copiar o arquivo ' + sPathOld + sArqOld + ' para ' + sPathNew + sArqNew );
    ShowMessage( 'Erro ao copiar o arquivo ' + sPathOld + sArqOld + ' para ' + sPathNew + sArqNew );
    sRetorno := '1';
  end;

  Result := sRetorno;

end;

//------------------------------------------------------------------------------
Function ExisteDir(sDiretorio : AnsiString) : Boolean;
begin
  Result := True;

  If not DirectoryExists(sDiretorio) then
  begin
    Result := CreateDir(sDiretorio);
  end
  
end;

//------------------------------------------------------------------------------
Procedure GravaLog( sTexto: AnsiString );
begin
  If LogDll
  Then WriteLog2('sigaloja.log',  DateToStr(Now) +  ' ' +
                 FormatDateTime('HH:nn:ss.zzz' , Now) + ' ' + sTexto);
end;

//------------------------------------------------------------------------------
Procedure GravaLogEmulNFisc( sTexto:AnsiString );
begin
  WriteLog2('EMUNFISCAL.log', DateToStr(Now) +  ' ' +
                  FormatDateTime('HH:nn:ss.zzz' , Now) + ' ' + sTexto);
end;

//------------------------------------------------------------------------------
Function GetDataHoraArq(sArquivo: AnsiString): AnsiString;
begin
   Try
     If Not FileExists(sArquivo) Then
     Begin
       //Quando carga da DLL era recebida de um protheus com login fora do padrão (exemplo: Active Directory, Fluig Identity), não consegue localizar o arquivo, sendo necessário informar o path 
       sArquivo := ExtractFilePath(Application.ExeName) + '\' + sArquivo;
     End;

     Result := FormatDateTime('dd/mm/yyyy hh:nn:ss', FileDateToDateTime(FileAge(sArquivo)));
   Except
     Result := FormatDateTime('dd/mm/yyyy hh:nn:ss', Date() );
   End;
end;

//------------------------------------------------------------------------------
Function GetVersao(sArquivo: AnsiString): AnsiString;
var
  _Size: DWORD;
  _VerInfo: Pointer;
  _ValueSize: DWORD;
  _Value: PVSFixedFileInfo;
  _Dummy: DWORD;
  _V1, _V2, _V3, _V4: Word;
begin
  _Size := GetFileVersionInfoSize(PChar(sArquivo), _Dummy) ;
  GetMem(_VerInfo, _Size);
  GetFileVersionInfo(PChar(sArquivo), 0, _Size, _VerInfo);
  VerQueryValue(_VerInfo, '\', Pointer(_Value), _ValueSize);
  with _Value^ do
  begin
    _V1 := dwFileVersionMS shr 16;
    _V2 := dwFileVersionMS and $FFFF;
    _V3 := dwFileVersionLS shr 16;
    _V4 := dwFileVersionLS and $FFFF;
  end;
  FreeMem(_VerInfo, _Size);
  Result := Copy(IntToStr(_V1), 1, 2) + '.' +
            Copy(IntToStr(_V2), 1, 2) + '.' +
            Copy(IntToStr(_V3), 1, 3) + '.' +
            Copy(IntToStr(_V4), 1, 2);
end;

//------------------------------------------------------------------------------
function Arredondar(Valor: Double; Dec: Integer): Double;
var
   Fator, Fracao , VlrRet, VlrInt: Extended;
begin
   Fator := IntPower(10, Dec);
   VlrRet:= StrToFloat(FloatToStr(Valor*Fator));
   VlrInt:= Int(VlrRet);
   Fracao:= Frac(VlrRet);

   If Fracao >= 0.5
   then VlrInt := VlrInt + 1
   else If Fracao <= -0.5
        then VlrInt := VlrInt - 1;

   Result := VlrInt/Fator;
end;

//------------------------------------------------------------------------------
function SubstituiStr (Variavel ,Localizar ,Substituir : AnsiString) : AnsiString;
var
Retorno: AnsiString;
Posicao: Integer;
begin
Retorno := Variavel;
//Obtendo a posição inicial da substring Localizar na AnsiString Localizar.
Posicao := Pos (Localizar, Retorno);
//Verificando se a substring Localizar existe.
while Posicao <> 0 do
   begin
   // Excluindo a Localizar.
   Delete(Retorno, Posicao, Length (Localizar));
   // Inserindo a AnsiString do parâmetro Substituir
   Insert(Substituir, Retorno , Posicao);
   // Verifica se tem mais algum caracter
   Posicao := Pos (Localizar, Retorno);
end;
Result := Retorno;
end;

//------------------------------------------------------------------------------
Function ContaChar(cTexto, cChar : AnsiString): Integer;
Var
   nI, nCount : Integer;
Begin
   nCount := 0;
   For nI := 1 To Length(cTexto) Do
      If UpperCase(cTexto[nI]) = UpperCase(cChar) Then
         Inc(nCount);

   Result := nCount;
End;

//---------------------------------------------------------------------------------------------------------
//Criada para remover as tags caso a impressora nao possua tratamento para o comando enviado pelo Protheus
//---------------------------------------------------------------------------------------------------------
Function RemoveTags( Mensagem : AnsiString): AnsiString;
var
    aTagsProtheus : array [1..31] of AnsiString;
    cMsg,cAuxTag : AnsiString;
    n : Integer;
begin

aTagsProtheus[	1	] := 	'<B>'	;
aTagsProtheus[	2	] := 	'<I>'	;
aTagsProtheus[	3	] := 	'<CE>'	;
aTagsProtheus[	4	] := 	'<S>'	;
aTagsProtheus[	5	] := 	'<E>'	;
aTagsProtheus[	6	] := 	'<C>'	;
aTagsProtheus[	7	] := 	'<N>'	;
aTagsProtheus[	8	] := 	'<L>'	;
aTagsProtheus[	9	] := 	'<SL>'	;
aTagsProtheus[	10	] := 	'<TC>'	;
aTagsProtheus[	11	] := 	'<TB>'	;
aTagsProtheus[	12	] := 	'<AD>'	;
aTagsProtheus[	13	] := 	'<FE>'	;
aTagsProtheus[	14	] := 	'<XL>'	;
aTagsProtheus[	15	] := 	'<GUI>'	;
aTagsProtheus[	16	] := 	'<EAN13>'	;
aTagsProtheus[	17	] := 	'<EAN8>'	;
aTagsProtheus[	18	] := 	'<UPC-A>'	;
aTagsProtheus[	19	] := 	'<CODE39>'	;
aTagsProtheus[	20	] := 	'<CODE93>'	;
aTagsProtheus[	21	] := 	'<CODABAR>'	;
aTagsProtheus[	22	] := 	'<MSI>'	;
aTagsProtheus[	23	] := 	'<CODE11>'	;
aTagsProtheus[	24	] := 	'<PDF>'	;
aTagsProtheus[	25	] := 	'<CODE128>'	;
aTagsProtheus[	26	] := 	'<I2OF5>'	;
aTagsProtheus[	27	] := 	'<S2OF5>'	;
aTagsProtheus[	28	] := 	'<QRCODE>'	;
aTagsProtheus[	29	] := 	'<BMP>'	;
aTagsProtheus[	30	] := 	'<CORRECAO>'	;
aTagsProtheus[	31	] := 	'<LMODULO>'	;

cMsg := Mensagem;

For n := 1 to 30 do
  while Pos( LowerCase(aTagsProtheus[n]) , cMsg ) > 0 do
  begin
     cMsg := StringReplace(cMsg,LowerCase(aTagsProtheus[n]),'',[]);
     cAuxTag := LowerCase(aTagsProtheus[n]);
     Insert( '/',cAuxTag,2);
     cMsg := StringReplace(cMsg,cAuxTag,'',[]);
  end;

Result := cMsg;
end;

//------------------------------------------------------------------------------
Function LimpaDir(cPath,cFile,cExtensao: AnsiString): Boolean;
var
  tFindFile : TSearchRec;
  cOrigem : AnsiString;
  iX : Integer;
begin
   Result := True;
   cOrigem  := cPath + cFile + cExtensao;
    iX := FindFirst(cOrigem,faAnyFile,tFindFile);
    While iX = 0 do
    begin
      If ( tFindFile.Attr and faDirectory ) <> faDirectory then
      begin
        cOrigem := cPath + tFindFile.Name;
        Result := System.SysUtils.DeleteFile(cOrigem);
      end;
      iX := FindNext(tFindFile);
    end;
end;

//------------------------------------------------------------------------------
Function ClearLog(): Boolean;
var
 iLogLoja: file of Byte;
 iTamanho: Longint;
 sNomeArq,sPathArq,sTamLogIni: AnsiString;
begin
sPathArq := ExtractFilePath(Application.ExeName) + '\';
sNomeArq := 'sigaloja.log';

If FileExists(sPathArq+sNomeArq) then
begin
  AssignFile(iLogLoja, sPathArq+sNomeArq); // Cria um ponteiro
  Reset(iLogLoja); // Abre o arquivo como somente leitura
  iTamanho := FileSize(iLogLoja); // Obtém o tamanho do arquivo  em bytes
  CloseFile(iLogLoja);

  sTamLogIni := LeArqIni(ExtractFilePath(Application.ExeName),
                     'sigaloja.ini', 'logdll', 'TamanhoLog', '5000' );

  if iTamanho >= (StrToInt(sTamLogIni)*1024)  then //Arquivo maior que o tamanho definido no INI, recria
  begin
    WriteLog2(sNomeArq,'****************************//***************************');
    System.SysUtils.RenameFile(sPathArq+sNomeArq,sPathArq+'sigaloja_'+ FormatDateTime('ddMMyyyyHHmmss',Now)+'_bak.log');
    System.SysUtils.DeleteFile(sPathArq+sNomeArq);
    WriteLog2(sNomeArq,'-');
  end;
end;

Result := True;
end;

Procedure GrvTempRedZ( aValor: Array of AnsiString) ;
Var
  sStrList: TStringList;
  sArqNew: AnsiString;
  i: Integer;
  dDataMovimento: TDate;
Begin
  Try
    dDataMovimento := StrToDate(aValor[0]); //Data do Movimento que sera emitido a Z

    sArqNew := ExtractFilePath(Application.ExeName)+'redz.tmp';   //arquivo com data do movimento

    //Verifica se existe arquivo
    If FileExists(sArqNew) Then
    Begin
      If System.SysUtils.DeleteFile( sArqNew )
      Then GravaLog('Backup Reducao Z: Arquivo deletado com sucesso - [' + sArqNew + ']')
      Else GravaLog('Backup Reducao Z: Não foi possível excluir o arquivo - ['+sArqNew +']');
    End;

    sStrList := TStringList.Create();

    For i:= 0 to High(aValor) do
    Begin
      sStrList.Add(aValor[i]);
    End;

    sStrList.SaveToFile(sArqNew);
    sStrList.Free;
    sStrList := Nil;

    GravaLog('Backup Reducao Z: Realizado com sucesso - ['+ sArqNew +']');
  Except
    //nao realiza tratamentos de erros para processo de gravação do backup da RedZ, evitando impacto no processo de execução padrao da Z
    GravaLog('Backup Reducao Z: Não realizado');
  End;
End;

//------------------------------------------------------------------------------
Function GetTempRedZ( sDataMovimento: AnsiString ) : TaString;
Var
  sStrList: TStringList;
  sArq: AnsiString;
  i: Integer;
  dDtMovIn,dDtMovZ: TDate;
  aTmpResult: TaString;
Begin
  Try

    sArq := ExtractFilePath(Application.ExeName)+'redz.tmp';   //arquivo com data do movimento

    If Not FileExists(sArq) Then
    Begin
      GravaLog('Backup Reducao Z: Não localizou arquivo de backup:'+sArq);
      Exit;
    End;

    sStrList := TStringList.Create();
    sStrList.LoadFromFile(sArq);

    SetLength(aTmpResult,sStrList.Count);

    For i:=0 to sStrList.Count-1 do
    Begin
      aTmpResult[i] := sStrList.Strings[i];
    End;

    If Length(aTmpResult) > 0 Then
    Begin
      dDtMovIn := StrToDate(sDataMovimento); //Data do Movimento solicitado
      dDtMovZ  := StrToDate(aTmpResult[0]); //Data do Movimento gravado em disco
    End;

    If dDtMovIn = dDtMovZ
    Then Result := aTmpResult
    Else GravaLog('Backup Reducao Z: Não foi possível restaurar dados da reducao Movimento:'+sDataMovimento);
  Except
      GravaLog('Backup Reducao Z: Não foi possível restaurar dados da reducao:'+sArq);
  End;
End;

//------------------------------------------------------------------------------
// a regra inserida aqui esta de acordo com o documento da SEFAZ
// https://svn.code.sf.net/p/acbr/code/tools/ECF/EscECF/ac1609.pdf
// que padroniza a questão de arredondamento no ECF CV 09/09
//------------------------------------------------------------------------------
Function ArredCV0909( xValor: Real ) : Currency;
Var
  sInteiro,sDecimal: AnsiString;
  iPos,nX,nY : Integer;
  aDecimais: array of Integer;
  bResult : Boolean;
  nValor  : Real;
Begin
  Result := 0;
  nValor := 0;
  bResult:= False;
  sInteiro := Trim(FloatToStr(xValor));
  GravaLog(' Valor : ' + sInteiro );

  iPos := Pos('.',sInteiro);
  If iPos > 0 then
  begin
    nX := Length(sInteiro);
    sDecimal := Copy(sInteiro,iPos+1,nX);
    sInteiro := Copy(sInteiro,1,iPos-1);

    nY := Length(sDecimal);
    SetLength(aDecimais,nY);
    For nX := 0 to Pred(nY) do
    begin
      aDecimais[nX] := StrToInt(sDecimal[nX+1]);
    end;

    If nY > 2 then
    begin
      //a regra esta embasada na Terceira Casa Decimal

      //** Se a terceira casa é menor que 5 = mantem
      If aDecimais[2] < 5 then
      begin
        nValor := StrToCurr(sInteiro + '.' + Copy(sDecimal,1,2));
        bResult:= True;
      end;

      //** Se a terceira casa é maior que 5 = acresce 1 unidade na segunda casa
      //** Se a terceira casa é igual a 5 e seguido de um algarismo diferente de zero = acresce 1 unidade na segunda casa
      If ( bResult = False ) And (( aDecimais[2] > 5 ) Or
                                 (( aDecimais[2] = 5 ) And (nY > 3) And (aDecimais[3] <> 0) )) then
      begin
        aDecimais[1] := aDecimais[1]+1;
        sDecimal[2]  := AnsiChar(IntToStr( aDecimais[1] )[1]);
        nValor := StrToCurr(sInteiro + '.' + Copy(sDecimal,1,2));
        bResult:= True;
      end;

      //** Se a terceira casa é igual a 5 e seguido de zeros = É arredondada para o algarismo 'par' mais próximo
      If ( bResult = False ) And
         ((aDecimais[2] = 5) And (nY > 3) And (aDecimais[3] = 0) Or
         ( not (nX > 3) ) ) then
      begin
        If (aDecimais[1] div 2) = 0 then
        begin
          nValor := StrToCurr(sInteiro + '.' + Copy(sDecimal,1,2));
          bResult:= True;
        end
        else
        begin //Se for impar, deve acrescer
          aDecimais[1] := aDecimais[1]+1;
          sDecimal[2]  := AnsiChar(IntToStr( aDecimais[1] )[1]);
          nValor := StrToCurr(sInteiro + '.' + Copy(sDecimal,1,2));
          bResult:= True;
        end;
      end;

      If bResult = False then
      begin
        nValor := StrToCurr(sInteiro + '.' + Copy(sDecimal,1,2));
        nValor := xValor;
      end;
    end
    else
      nValor := xValor;
  end
  else
    nValor := xValor;

  Result := nValor;  
End;


//Criada para substituir a função CopyFile devido a falha
// na conversão das variáveis strings
function CopiarArquivo( Const sourcefilename, targetfilename: AnsiString ): Boolean;
Var
  S, T: TFileStream;
  bExist : Boolean;
Begin
  bExist := FileExists(sourcefilename);
  if bExist then
  begin
    S := TFileStream.Create( sourcefilename, fmOpenRead );
    try
      T := TFileStream.Create( targetfilename, fmOpenWrite or fmCreate );
      try
        T.CopyFrom(S, S.Size ) ;
      finally
        T.Free;
      end;
    finally
      S.Free;
    end;

    bExist := FileExists(targetfilename);
  end;

  Result := bExist;
End;

end.


