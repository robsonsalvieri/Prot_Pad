unit e1_impressora;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, dl, funcoesGenericas, Unix;

//Funções utilizadas para chamar as rotinas da e1_impressora.so
function GetVersaoDLL():string;
function AbreConexaoImpressora(libE1Impressora: Pointer; tipo: integer; modelo: string; conexao: string; parametro: integer):integer;
function FechaConexaoImpressora(libE1Impressora: Pointer):integer;
function ImpressaoTexto(libE1Impressora: Pointer; dados: string; posicao: integer; stilo: integer; tamanho: integer):integer;
function Corte(libE1Impressora: Pointer; avanco: integer): integer;
function ImprimeImagem(libE1Impressora: Pointer; path: string): integer;
function ImpressaoCodigoBarras(libE1Impressora: Pointer; tipo: integer; dados: string; altura: integer; largura: integer; hri: integer): Integer;
function AbreGavetaElgin(libE1Impressora: Pointer): integer;
function DefinePosicao(libE1Impressora: Pointer; posicao: integer): integer;
function AvancaPapel(libE1Impressora: Pointer; linhas: integer): integer;
function ImpressaoQRCode(libE1Impressora: Pointer; dados: string; tamanho: integer; nivelCorrecao: integer): integer;
function StatusImpressora(libE1Impressora: Pointer; param: integer): integer;

//Funções de tratamento genéricas
function TrataTags( var Texto: string ): string;
procedure AlimentaTags();

type
  TAbreConexaoImpressora = function(tipo: integer; modelo: string; conexao: string; parametro: integer):integer; cdecl;
  TFechaConexaoImpressora = function ():integer; cdecl;
  TImpressaoTexto = function (dados: string; posicao: integer; stilo: integer; tamanho: integer):integer; cdecl;
  TCorte = function (avanco: integer):integer; cdecl;
  TImprimeImagem = function (path: string): integer; cdecl;
  TImpressaoCodigoBarras = function (tipo: integer; dados: string; altura: integer; largura: integer; hri: integer): integer; cdecl;
  TAbreGavetaElgin = function ():integer; cdecl;
  TDefinePosicao = function (posicao: integer):integer; cdecl;
  TAvancaPapel = function (linhas: integer): integer; cdecl;
  TImpressaoQRCode = function (dados: string; tamanho: integer; nivelCorrecao: integer): integer; cdecl;
  TStatusImpressora = function (param: integer): integer; cdecl;

implementation

var
   aArTags: array [1..27] of string;

function GetVersaoDLL():string;
begin
  Result := '1.1.1.1';
end;

function AbreConexaoImpressora(libE1Impressora: Pointer; tipo: integer; modelo: string; conexao: string; parametro: integer):integer;
var
  E1AbreConexaoImpressora: TAbreConexaoImpressora;
begin

  Pointer(E1AbreConexaoImpressora) := dlsym(libE1Impressora,'AbreConexaoImpressora');
  if Assigned(E1AbreConexaoImpressora) then
  begin
    Result := E1AbreConexaoImpressora(tipo, modelo, conexao, parametro);
  end;

end;

function FechaConexaoImpressora(libE1Impressora: Pointer):integer;
var
  E1FechaConexaoImpressora: TFechaConexaoImpressora;
begin

  Pointer(E1FechaConexaoImpressora) := dlsym(libE1Impressora,'FechaConexaoImpressora');
  if Assigned(E1FechaConexaoImpressora) then
  begin
    Result := E1FechaConexaoImpressora();
  end;

end;

function ImpressaoTexto(libE1Impressora: Pointer; dados: string; posicao: integer; stilo: integer; tamanho: integer):integer;
var
  iRet,nPos: Integer;
  oTexto : TStringList;
  sAux,sTextoImp,sTextoEnv,sAuxCBar,cAuxText,cArTagGui,sAuxQR,sAuxBMP : String;
  bCorte : Boolean;
  E1ImpressaoTexto: TImpressaoTexto;
begin

  Pointer(E1ImpressaoTexto) := dlsym(libE1Impressora,'ImpressaoTexto');

  if Assigned(E1ImpressaoTexto) then
  begin
    Sleep(1000);
    iRet := 0; //StatusImpressora(libE1Impressora, 5); //Retiramos o status ate o time da Elgin corrigir essa função, pois esta sempre retornando status -81.

    if iRet = 0 then
    begin

      bCorte    := False;
      sTextoImp := dados;
      oTexto    := TStringList.Create;
      AlimentaTags();

      oTexto.Clear;

      //Inicio - Apenas corta o papel
      sAux := aArTags[12];
      Insert('/',sAux,2);
      If Concat(aArTags[12],sAux) = sTextoImp then
      begin
        bCorte := true;
        iRet := Corte(libE1Impressora, 5);
        Result := iRet;
      end;
      //Fim - Apenas corta o papel

      If not bCorte then
      begin
        sAux := '';
        nPos := Pos(#10,sTextoImp);

        While nPos > 0 do
        Begin
          nPos := Pos(#10,sTextoImp);
          If (nPos = 0) and (sTextoImp <> '') then
             nPos := Length(sTextoImp);

          sAux := Copy(sTextoImp,1,nPos);
          sAux := LimpaAcentuacao(sAux);

          //Tratamento para que a impressora Bematech não considere o "-" como
          //caracter especial
          If Pos('–',sAux) > 0 then
             sAux := StringReplace(sAux,'–','-',[]);

          //Removo as tags que a impressora ignora e imprime como texto
          sAux := RemoveTags(sAux);

          If Pos('<bmp>',sAux) > 0 then
          begin
             sAuxBMP := ExtraiTag(sAux,'<bmp>','</bmp>');
             sTextoImp := Copy(sTextoImp,nPos+1,Length(sTextoImp));
          end
          else
          begin
             //Converto a string para UTF8 para a E1_Impressora01.dll não imprimir os
             //caracteres especiais
             sAux := UTF8Encode(sAux);
             oTexto.Add(sAux);
             sTextoImp := Copy(sTextoImp,nPos+1,Length(sTextoImp));
             If sTextoImp = '' then
                nPos := 0
          end;
        end;

        If TrataTags(dados) = 'S' then
        begin

          //Caso seja enviado um logo, imprime no cabeçalho do Cupom Não-Fiscal
          If sAuxBMP <> '' then
             iRet := ImprimeImagem(libE1Impressora, sAuxBMP);

          For nPos := 0 to Pred(oTexto.Count) do
          Begin
             sTextoEnv := oTexto.Strings[nPos];

             //Variavel responsavel por acionar a guilhotina caso tenha a tag <gui>
             If Pos(aArTags[12],sTextoEnv) > 0 then
                bCorte := True;

             //Verifica se ultimo caracter ? #10 e remove para nao duplicar o espaco entre linhas
             If Copy(sTextoEnv,Length(sTextoEnv),1) = #10
                then sTextoEnv := Copy(sTextoEnv,1,Length(sTextoEnv)-1);

             If Pos(aArTags[23],sTextoEnv) > 0 then //aArTags[23] == <code128>
             begin
                sAuxCBar := ExtraiTag(oTexto.Strings[nPos],'<code128>','</code128>');
                Insert('{C',sAuxCBar,1);
                iRet := DefinePosicao(libE1Impressora, 1);
                iRet := ImpressaoCodigoBarras(libE1Impressora, 8, sAuxCBar, 70, 2, 4);
                iRet := AvancaPapel(libE1Impressora, 2);
             end
             else If Pos(aArTags[25],sTextoEnv) > 0 then //aArTags[25] == <qrcode>
             begin
                sAuxQR := ExtraiTag(oTexto.Strings[nPos],'<qrcode>','</qrcode>');
                iRet := DefinePosicao(libE1Impressora, 1);
                iRet := ImpressaoQRCode(libE1Impressora, sAuxQR, 4, 2);
             end
             else If Pos(aArTags[1],sTextoEnv) > 0 then //aArTags[1] == <b>
             begin
                cAuxText := StringReplace(oTexto.Strings[nPos],'</b>','',[rfReplaceAll]);
                cAuxText := StringReplace(cAuxText,'<b>','',[rfReplaceAll]);
                iRet := E1ImpressaoTexto(cAuxText,1,9,0);
             end
             else If (Pos(aArTags[12],sTextoEnv) = 0) and (Trim(sTextoEnv) <> '') then
                iRet := E1ImpressaoTexto(oTexto.Strings[nPos],1,1,0)
             else If Trim(sTextoEnv) = '' then
                iRet := AvancaPapel(libE1Impressora, 1);

             //Acionar a guilhotina caso tenha a tag <gui>
             If bCorte then
             begin
                iRet := Corte(libE1Impressora, 5);
                bCorte := False;
             end;

          End;
        end
        else
        begin
          For nPos := 0 to Pred(oTexto.Count) do
             iRet := E1ImpressaoTexto(oTexto.Strings[nPos],0,0,0);
        end;

        Result := iRet
      end;
    end
    else
    begin
      Result := iRet;
    end;
  end
  else
  begin
    Result := -1
  end;
end;

function Corte(libE1Impressora: Pointer; avanco: integer): integer;
var
  E1Corte: TCorte;
begin
  Pointer(E1Corte) := dlsym(libE1Impressora,'Corte');
  if Assigned(E1Corte) then
  begin
    Result := E1Corte(avanco);
  end;
end;

function ImprimeImagem(libE1Impressora: Pointer; path: string): integer;
var
  E1ImprimeImagem: TImprimeImagem;
begin

  Pointer(E1ImprimeImagem) := dlsym(libE1Impressora,'ImprimeImagem');
  if Assigned(E1ImprimeImagem) then
  begin
    Result := E1ImprimeImagem(path);
  end;

end;

function ImpressaoCodigoBarras(libE1Impressora: Pointer; tipo: integer; dados: string; altura: integer; largura: integer; hri: integer): Integer;
var
  E1ImpressaoCodigoBarras: TImpressaoCodigoBarras;
begin

  Pointer(E1ImpressaoCodigoBarras) := dlsym(libE1Impressora,'ImpressaoCodigoBarras');
  if Assigned(E1ImpressaoCodigoBarras) then
  begin
    Result := E1ImpressaoCodigoBarras(tipo, dados, altura, largura, hri);
  end;

end;

function AbreGavetaElgin(libE1Impressora: Pointer): integer;
var
  E1AbreGavetaElgin: TAbreGavetaElgin;
begin
  Pointer(E1AbreGavetaElgin) := dlsym(libE1Impressora,'AbreGavetaElgin');
  if Assigned(E1AbreGavetaElgin) then
  begin
    Result := E1AbreGavetaElgin();
  end;
end;

function DefinePosicao(libE1Impressora: Pointer; posicao: integer): integer;
var
  E1DefinePosicao: TDefinePosicao;
begin
  Pointer(E1DefinePosicao) := dlsym(libE1Impressora,'DefinePosicao');
  if Assigned(E1DefinePosicao) then
  begin
    Result := E1DefinePosicao(posicao);
  end;
end;

function AvancaPapel(libE1Impressora: Pointer; linhas: integer): integer;
var
  E1AvancaPapel: TAvancaPapel;
begin
  Pointer(E1AvancaPapel) := dlsym(libE1Impressora,'AvancaPapel');
  if Assigned(E1AvancaPapel) then
  begin
    Result := E1AvancaPapel(linhas);
  end;
end;

function ImpressaoQRCode(libE1Impressora: Pointer; dados: string; tamanho: integer; nivelCorrecao: integer): integer;
var
  E1ImpressaoQRCode: TImpressaoQRCode;
begin
  Pointer(E1ImpressaoQRCode) := dlsym(libE1Impressora,'ImpressaoQRCode');
  if Assigned(E1ImpressaoQRCode) then
  begin
    Result := E1ImpressaoQRCode(dados, tamanho, nivelCorrecao);
  end;
end;

function StatusImpressora(libE1Impressora: Pointer; param: integer): integer;
var
  E1StatusImpressora: TStatusImpressora;
  nRet: integer;
  sMsg: string;
begin
  Pointer(E1StatusImpressora) := dlsym(libE1Impressora,'StatusImpressora');
  if Assigned(E1StatusImpressora) then
  begin
    nRet := E1StatusImpressora(param);

    case nRet of
      0: sMsg := 'Impressora OK';
      1: sMsg := 'Gaveta aberta';
      2: sMsg := 'Tampa da impressora aberta, verifique!';
      4: sMsg := 'Impressora com pouco papel, verifique!';
      12: sMsg := 'Impressora sem papel, verifique!';
      24: sMsg := 'Impressora Online';
    else
      sMsg := 'Retorno de status desconhecido: ' + IntToStr(nRet) + '. Por favor, verifique o manual do fabricante!';
    end;

    If (nRet = 0) or (nRet = 24) or (nRet = 1) then
      Result := 0
    else
    begin
      fpSystem('zenity --info --text="' + sMsg  + '"');
      GravaLog(sMsg);
      Result := -1
    end;
  end;
end;

function TrataTags( var Texto: string ): string;
var
   sRet,sAux,sCorrigeQrCode : String;
   nX : Integer;
begin
  sRet := '';


  //------------------------------------------------
  //Caso o Texto venha com comando de impressão de
  //QrCode deve manda comando para ajustar o tamanho
  //do mesmo
  //------------------------------------------------
  nX := Pos( aArTags[25],Texto);
  If (nX > 0) And (Pos( aArTags[26],Texto) = 0) then
  begin
    sAux := aArTags[26];
    Insert('/',sAux,2); //cria a tag de fechamento
    sCorrigeQrCode := aArTags[26] + '5' + sAux;

    sAux := aArTags[25];
    Insert('/',sAux,2); //cria a tag de fechamento
    nX := Pos(sAux,Texto);
    Insert(sCorrigeQrCode,Texto,nX); //Deve inserir a tag de ajuste antes da tag de fechamento do qrcode (</qrcode>)
  end;

  For nX:= 1 to 27 do
  begin
    If Pos(aArTags[nX],Texto) > 0 then
    begin
      sRet := 'S';
      Result := sRet;
      Exit;
    end;
  end;

  Result := sRet;
end;

procedure AlimentaTags();
begin
  If aArTags[1] = '' then
  begin
    aArTags[1] := '<b>';
    aArTags[2] := '<ad>';
    aArTags[3] := '<s>';
    aArTags[4] := '<e>';
    aArTags[5] := '<c>';
    aArTags[6] := '<n>';
    aArTags[7] := '<l>';
    aArTags[8] := '<ce>';
    aArTags[9] := '<da>';
    aArTags[10] := '<xl>';
    aArTags[11] := '<g>';
    aArTags[12] := '<gui>';
    aArTags[13] := '<bmp>';
    aArTags[14] := '<ibmp>';
    aArTags[15] := '<cespl>';
    aArTags[16] := '<upc-a>';
    aArTags[17] := '<ean13>';
    aArTags[18] := '<ean8>';
    aArTags[19] := '<code39>';
    aArTags[20] := '<code93>';
    aArTags[21] := '<codabar>';
    aArTags[22] := '<i2of5>';
    aArTags[23] := '<code128>';
    aArTags[24] := '<pdf>';
    aArTags[25] := '<qrcode>';
    aArTags[26] := '<lmodulo>';
    aArTags[27] := '<correcao>';
  end;
end;

end.

