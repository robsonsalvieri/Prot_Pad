unit funcoesGenericas;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, IniFiles;

var
  GravaLogAtivo: string = '';

procedure GravaLog(Msg: string; Forca: boolean = false);
function LerArquivoIni(Secao: string; Identificador: string):string;
function RemoveTags(Texto: string):string;
function LimpaAcentuacao(Texto:String):String;
function ExtraiTag( aText, OpenTag, CloseTag: string ):string;
function StrTran( sTexto, sOrigem, sDestino:string):string;

implementation

procedure GravaLog(Msg: string; Forca: boolean = false);
var
  Arq: TextFile;
  NomeArquivo: string;
  Log: string = '';
begin
  if (GravaLogAtivo = '1') or (Forca) then
  begin
    NomeArquivo := ExtractFilePath(ParamStr(0)) + 'libsigaloja_linux.log';
    AssignFile(Arq, NomeArquivo);

    Log += FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) + ' - ' + Msg ;

    if FileExists(NomeArquivo) then
      Append(Arq)
    else
      Rewrite(Arq);

    WriteLn(Arq,Log);

    CloseFile(Arq);
  end;
end;

function LerArquivoIni(Secao: string; Identificador: string):string;
var
  FileIni: TIniFile;
  CaminhoIni: string;
  Conteudo: string;
begin
  CaminhoIni := ExtractFilePath(ParamStr(0)) + 'libsigaloja_linux.ini';

  if FileExists(CaminhoIni) then
  begin
    FileIni := TIniFile.Create(CaminhoIni);
    Conteudo := FileIni.ReadString(Secao,Identificador,'');
    Result := Conteudo;
    GravaLog('Leitura do libsigaloja_linux.ini no caminho (' + CaminhoIni + ') - Secao: ' + Secao + ' - Identificador: ' + Identificador + ' - Conteúdo: ' + Result, true);
  end
  else
  begin
    Result := '';
    GravaLog('Arquivo libsigaloja_linux.ini nao localizado no caminho (' + CaminhoIni + ')', true);
  end;

end;

function RemoveTags(Texto: string):string;
var
  sRet: string;
begin
  sRet := Texto;
  sRet := StringReplace(sRet,'</ce>','',[rfReplaceAll]);
  sRet := StringReplace(sRet,'<ce>','',[rfReplaceAll]);
  sRet := StringReplace(sRet,'</c>','',[rfReplaceAll]);
  sRet := StringReplace(sRet,'<c>','',[rfReplaceAll]);

  Result := sRet;
end;

function LimpaAcentuacao(Texto:String):String;
var
  i : Integer;
  aCarac01 : TStringList;
  aCarac02 : TStringList;
begin

  aCarac01 := TStringList.Create;
  aCarac02 := TStringList.Create;

  aCarac01.Add('á'); aCarac02.Add('a');
  aCarac01.Add('ã'); aCarac02.Add('a');
  aCarac01.Add('â'); aCarac02.Add('a');
  aCarac01.Add('ä'); aCarac02.Add('a');
  aCarac01.Add('é'); aCarac02.Add('e');
  aCarac01.Add('ê'); aCarac02.Add('e');
  aCarac01.Add('é'); aCarac02.Add('e');
  aCarac01.Add('ë'); aCarac02.Add('e');
  aCarac01.Add('í'); aCarac02.Add('i');
  aCarac01.Add('ó'); aCarac02.Add('o');
  aCarac01.Add('õ'); aCarac02.Add('o');
  aCarac01.Add('ó'); aCarac02.Add('o');
  aCarac01.Add('ô'); aCarac02.Add('o');
  aCarac01.Add('ö'); aCarac02.Add('o');
  aCarac01.Add('”'); aCarac02.Add('o');
  aCarac01.Add('ú'); aCarac02.Add('u');
  aCarac01.Add('û'); aCarac02.Add('u');
  aCarac01.Add('ü'); aCarac02.Add('u');
  aCarac01.Add('ç'); aCarac02.Add('c');
  aCarac01.Add('‚'); aCarac02.Add('e');
  aCarac01.Add('¢'); aCarac02.Add('o');
  aCarac01.Add('ˆ'); aCarac02.Add('e');
  aCarac01.Add('‡'); aCarac02.Add('c');
  aCarac01.Add(' '); aCarac02.Add('a');
  aCarac01.Add('Á'); aCarac02.Add('A');
  aCarac01.Add('Ã'); aCarac02.Add('A');
  aCarac01.Add('Â'); aCarac02.Add('A');
  aCarac01.Add('Ä'); aCarac02.Add('A');
  aCarac01.Add('É'); aCarac02.Add('E');
  aCarac01.Add('Ê'); aCarac02.Add('E');
  aCarac01.Add('É'); aCarac02.Add('E');
  aCarac01.Add('Ë'); aCarac02.Add('E');
  aCarac01.Add('Í'); aCarac02.Add('I');
  aCarac01.Add('Ó'); aCarac02.Add('O');
  aCarac01.Add('Õ'); aCarac02.Add('O');
  aCarac01.Add('Ó'); aCarac02.Add('O');
  aCarac01.Add('Ô'); aCarac02.Add('O');
  aCarac01.Add('Ö'); aCarac02.Add('O');
  aCarac01.Add('”'); aCarac02.Add('O');
  aCarac01.Add('Ú'); aCarac02.Add('U');
  aCarac01.Add('Û'); aCarac02.Add('U');
  aCarac01.Add('Ü'); aCarac02.Add('U');
  aCarac01.Add('Ç'); aCarac02.Add('C');

  For i:=0 to aCarac01.Count-1 do
    Texto := StrTran(Texto,aCarac01.Strings[i],aCarac02.Strings[i]);

  aCarac01.Free;
  aCarac02.Free;

  Result := Texto;

end;

function ExtraiTag( aText, OpenTag, CloseTag: string ):string;
var
  iAux, kAux : Integer;
begin
  Result := '';

  if (Pos(CloseTag, aText) <> 0) and (Pos(OpenTag, aText) <> 0) then
  begin
    iAux := Pos(OpenTag, aText) + Length(OpenTag);
    kAux := Pos(CloseTag, aText);
    Result := Copy(aText, iAux, kAux-iAux);
  end;
end;

function StrTran( sTexto, sOrigem, sDestino:String):String;
var
  sRet: String;
  nPos: Integer;
begin
  sRet := sTexto;
  //Verifica se possui String para substituir
  nPos := Pos (sOrigem, sRet);
  while nPos <> 0 do
  begin
    //Exclui texto que sera substituido
    Delete(sRet, nPos, Length (sOrigem));
    //Insere novo texto
    Insert(sDestino, sRet , nPos);
    //Verifica se possui mais String para substituir
    nPos := Pos (sOrigem, sRet);
  end;

  Result := sRet;
end;

end.

