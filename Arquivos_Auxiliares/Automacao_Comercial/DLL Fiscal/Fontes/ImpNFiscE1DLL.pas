unit ImpNFiscE1DLL;

interface

uses
  Dialogs, ImpNFiscMain, Windows, SysUtils, classes, LojxFun,
  IniFiles, Forms, CMC7Main, StdCtrls, ShellApi;

type

  TImpNfE1DLL = class(TImpNFiscal)//TStringList
  private
  public
    function Abrir( sPorta:String; iVelocidade : Integer; iHdlMain:Integer ):String; override;
    function Fechar( sPorta:String ):String; override;
    function ImpTexto( Texto : String):String; override;
    function ImpBitMap( Arquivo:String ):String; override;
    function TrataTags( var Texto : String ): String;
    function ExtraiTag( aText, OpenTag, CloseTag : String ) : String;
    function VerStatus(): Integer;
    function AbreGaveta() : String; override;
    function RemoveTags( var Texto : String ) : String;
  end;

  Function OpenNFE1DLL( sPorta:String; iVelocidade : Integer ):String;
  Function CloseNFE1DLL : String;

implementation

var
        fHandle  : THandle; //'E1_Impressora01.DLL'
        aArTags : array [1..27] of String;

        //Funções da DLL
        AbreConexaoImpressora      :function(tipo:Integer; modelo: String  ; conexao:String; parametro:Integer)  : Integer; StdCall;
        FechaConexaoImpressora     :function(): Integer; StdCall;
        EspacamentoEntreLinhas     :function(tamanho:Integer): Integer; StdCall;
        ImpressaoTexto         	   :function(dados:String;  posicao:Integer; stilo:Integer;tamanho:Integer): Integer; StdCall;
        Corte                      :function(avanco:Integer) : Integer; StdCall;
        CorteTotal                 :function(avanco:Integer) : Integer; StdCall;
        ImpressaoQRCode            :function(dados:String; tamanho:Integer; nivelCorrecao:Integer): Integer; StdCall;
        ImpressaoPDF417            :function(numCols:Integer; numRows:Integer; width:Integer; height:Integer; errCorLvl:Integer; options:Integer; dados:String): Integer; StdCall;
        ImpressaoCodigoBarras      :function(tipo:Integer; dados:String;  altura:Integer; largura:Integer; HRII:Integer): Integer; StdCall;
        AvancaPapel                :function(linhas:Integer): Integer; StdCall;
        StatusImpressora           :function(param:Integer): Integer; StdCall;
        AbreGavetaElgin            :function(): Integer; StdCall;
        AbreGaveta                 :function(pino:Integer;  ti:Integer; tf:Integer): Integer; StdCall;
        InicializaImpressora       :function(): Integer; StdCall;
        DefinePosicao              :function(posicao:Integer): Integer; StdCall;
        SinalSonoro                :function(qtd:Integer; tempoInicio:Integer; tempoFim:Integer): Integer; StdCall;
        DirectIO                   :function(writeData:String; writeNum:Integer; readData:String; readNum:Integer): Integer; StdCall;
        ImprimeImagemMemoria       :function(key:char;scala:Integer) : Integer; StdCall;
        ImprimeXMLSAT              :function(dados:char ; param:Integer): Integer; StdCall;
        ImprimeXMLCancelamentoSAT  :function(dados:char; assQRCode:char; param:Integer): Integer; StdCall;
        ImprimeXMLNFCe             :function(dados:char; indexcsc:Integer;csc:char; param:Integer): Integer; StdCall;
        ImprimeXMLCancelamentoNFCe :function(dados:char; param:Integer): Integer; StdCall;
        ModoPagina                 :function(): Integer; StdCall;
        DirecaoImpressao           :function(direcao:Integer): Integer; StdCall;
        DefineAreaImpressao        :function(oHorizontal:Integer; oVertical:Integer; dHorizontal:Integer;dVertical:Integer): Integer; StdCall;
        PosicaoImpressaoHorizontal :function(nLnH:Integer): Integer; StdCall;
        PosicaoImpressaoVertical   :function(nLnH:Integer): Integer; StdCall;
        ImprimeModoPagina          :function(): Integer; StdCall;
        LimpaBufferModoPagina      :function(): Integer; StdCall;
        ImprimeMPeRetornaPadrao    :function(): Integer; StdCall;
        ModoPadrao                 :function(): Integer; StdCall;
        ImprimeCupomTEF            :function(dados:char): Integer; StdCall;
        ImprimeImagem              :function(path:String): Integer; StdCall;

        bOpened : Boolean;

//----------------------------------------------------------------------------
Function OpenNFE1DLL( sPorta:String; iVelocidade : Integer) : String;
  function ValidPointer( aPointer: Pointer; sMSg:String; sArqDll:String = 'E1_Impressora01.DLL' ) : Boolean;
  begin
    if not Assigned(aPointer) Then
    begin
      LjMsgDlg('A função "' + sMsg + '" não existe na Dll: ' + sArqDll +#13+
               '(Atualize as DLLs do Fabricante do ECF)');
      GravaLog('A função "' + sMsg + '" não existe na Dll: ' + sArqDll +#13+
               '(Atualize as DLLs do Fabricante do ECF)');
      Result := False;
    end
    else
      Result := True;
  end;

var
  aFunc: Pointer;
  iRet,iVelIni,tipo,parametro : Integer;
  bRet : Boolean;
  sPathLog,sVelIni,sIni,modelo,conexao : String;
  fArq : TIniFile;
  ListaArq : TStringList;
begin
  sPathLog  := '';

  If Not bOpened Then
  Begin
    fHandle  := LoadLibrary( 'E1_Impressora01.DLL' );

    if (fHandle <> 0) Then
    begin
      bRet := True;

      aFunc := GetProcAddress(fHandle,'AbreConexaoImpressora');
      if ValidPointer( aFunc, 'AbreConexaoImpressora' )
      then AbreConexaoImpressora := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'FechaConexaoImpressora');
      If ValidPointer( aFunc , 'FechaConexaoImpressora' )
      then FechaConexaoImpressora := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'ImpressaoTexto');
      If ValidPointer( aFunc , 'ImpressaoTexto' )
      then ImpressaoTexto := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'ImpressaoCodigoBarras');
      If ValidPointer( aFunc , 'ImpressaoCodigoBarras' )
      then ImpressaoCodigoBarras := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'CorteTotal');
      If ValidPointer( aFunc , 'CorteTotal' )
      then CorteTotal := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'AvancaPapel');
      If ValidPointer( aFunc , 'AvancaPapel' )
      then AvancaPapel := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'StatusImpressora');
      If ValidPointer( aFunc , 'StatusImpressora' )
      then StatusImpressora := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'ImpressaoQRCode');
      If ValidPointer( aFunc , 'ImpressaoQRCode' )
      then ImpressaoQRCode := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'AbreGaveta');
      If ValidPointer( aFunc , 'AbreGaveta' )
      then AbreGaveta := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'AbreGavetaElgin');
      If ValidPointer( aFunc , 'AbreGavetaElgin' )
      then AbreGavetaElgin := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'ImprimeImagem');
      If ValidPointer( aFunc , 'ImprimeImagem' )
      then ImprimeImagem := aFunc
      else bRet := False;

      aFunc := GetProcAddress(fHandle,'DefinePosicao');
      If ValidPointer( aFunc , 'DefinePosicao' )
      then DefinePosicao := aFunc
      else bRet := False;

    end
    else
    begin
      LjMsgDlg('A dll E1_Impressora01 não foi encontrado.');
      bRet := False;
    end;

    if bRet then
    begin
      If Copy(sPorta,1,3) = 'COM' then  //Quando porta COM deve setar a velocidade
      begin
        GravaLog('Impressora Nao Fiscal -> ConfiguraSerial ');

        LjMsgDlg('A DLL E1_Impressora01.dll não suporta a comunicação COM, é necessário utilizar a comunicação via USB.' + CHR(10)+CHR(13)+
                 'Favor verificar o cadastro de estação e/ou a instalação do driver da Impressora.');

        GravaLog('A DLL E1_Impressora01.dll não suporta a comunicação COM, é necessário utilizar a comunicação via USB.' + CHR(10)+CHR(13)+
                 'Favor verificar o cadastro de estação e/ou a instalação do driver da Impressora.');

        iRet := 1;
      end;

      GravaLog('Impressora Nao Fiscal -> AbreConexaoImpressora :' + sPorta);

      //Tratamento para impressão via REDE
      If sPorta = 'USB' then
         iRet := AbreConexaoImpressora(1, 'MP-4200', 'USB', 0)
      else If Copy(sPorta,1,3) <> 'COM' then
         iRet := AbreConexaoImpressora(3, 'MP-4200', sPorta, 9100);

      GravaLog('Impressora Nao Fiscal <- AbreConexaoImpressora : ' + IntToStr(iRet));

      If iRet <> 0 then
      begin
        LjMsgDlg('Impressora Nao Fiscal -> Erro na abertura da porta');
        GravaLog('Impressora Nao Fiscal -> Erro na abertura da porta');
        Result := '1|';
      end
      else
      begin
       bOpened := True;
       sPathLog := ExtractFilePath(Application.ExeName);

       If iRet = 0
       then GravaLog('Impressora Nao Fiscal -> Arquivo de Log de Impressora Habilitado em : "' + sPathLog + '"')
       else GravaLog('Impressora Nao Fiscal -> Arquivo de Log nao Habilitado ');

       Result := '0|';
      end;
    end
    else Result := '1|';
  end;
end;

//----------------------------------------------------------------------------
Function CloseNFE1DLL : String;
Var
  iRet : Integer;
begin
  If bOpened Then
  Begin
    If fHandle <> INVALID_HANDLE_VALUE then
    begin
      GravaLog('Impressora Nao Fiscal -> FechaConexaoImpressora ');
      iRet := FechaConexaoImpressora();
      GravaLog('Impressora Nao Fiscal <- FechaConexaoImpressora :' + IntToStr(iRet));

      FreeLibrary(fHandle);
      fHandle := 0;
    end;

    bOpened := False;
  End;
  Result := '0';
end;

//----------------------------------------------------------------------------
function TImpNfE1DLL.Abrir(sPorta : String; iVelocidade : Integer ; iHdlMain:Integer) : String;
Var
  sRet : String;
begin

If Not bOpened
Then sRet := OpenNFE1DLL(sPorta, iVelocidade )
Else sRet := '0|';

If Copy(sRet,1,1) = '0'
then GravaLog('Impressora Nao Fiscal : Sucesso ao abrir porta');

Result := sRet;

end;

//----------------------------------------------------------------------------
function TImpNfE1DLL.Fechar( sPorta:String ):String;
begin
Result := CloseNFE1DLL;
end;

//----------------------------------------------------------------------------
function TImpNfE1DLL.ImpTexto( Texto : String):String;
var
  iRet,nPos,nPosIni,nPosFim : Integer;
  oTexto : TStringList;
  sAux,sTextoImp,sTextoEnv,sAuxCBar,cAuxText,cArTagsCe,cArTagGui,sAuxQR,sAuxBMP : String;
  bCorte : Boolean;
begin
bCorte    := False;
sTextoImp := Texto;
oTexto    := TStringList.Create;
oTexto.Clear;
cArTagsCe := '<ce>';
cArTagGui := '<gui>';

//Verifica se vai efetuar corte de papel
sAux := aArTags[12];
Insert('/',sAux,2);
if Concat(aArTags[12],sAux) = sTextoImp then
begin
  bCorte := True;

  iRet := VerStatus();

  If iRet = 0 then
  begin
    GravaLog('Impressora Nao Fiscal -> AcionaGuilhotina ');
    iRet := CorteTotal(5); //Manda corte inteiro
    GravaLog('Impressora Nao Fiscal <- AcionaGuilhotina :' + IntToStr(iRet));
  end;

  If iRet = 0
  then Result := '0|'
  else Result := '1|';
end;

If not bCorte then
begin
  sAux := '';
  iRet := VerStatus();

  If iRet = 0 then
  begin
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

    End;

    If TrataTags(Texto) = 'S' then
    begin
      GravaLog('Impressora Nao Fiscal -> ImpressaoCupomNF : ' + Texto);

      //Caso seja enviado um logo, imprime no cabeçalho do Cupom Não-Fiscal
      If sAuxBMP <> '' then
         iRet := ImprimeImagem(sAuxBMP);

      For nPos := 0 to Pred(oTexto.Count) do
      Begin
         sTextoEnv := oTexto.Strings[nPos];

         //Variavel responsavel por acionar a guilhotina caso tenha a tag <gui>
         If Pos(cArTagGui,sTextoEnv) > 0 then
            bCorte := True;

         //Verifica se ultimo caracter ? #10 e remove para nao duplicar o espaco entre linhas
         If Copy(sTextoEnv,Length(sTextoEnv),1) = #10
            then sTextoEnv := Copy(sTextoEnv,1,Length(sTextoEnv)-1);

         If Pos(aArTags[23],sTextoEnv) > 0 then //aArTags[23] == <code128>
         begin
            sAuxCBar := ExtraiTag(oTexto.Strings[nPos],'<code128>','</code128>');
            Insert('{C',sAuxCBar,1);
            DefinePosicao(1);
            iRet := ImpressaoCodigoBarras(8,sAuxCBar,70,2,4);
            iRet := AvancaPapel(2);
         end
         else If Pos(aArTags[25],sTextoEnv) > 0 then //aArTags[25] == <qrcode>
         begin
            sAuxQR := ExtraiTag(oTexto.Strings[nPos],'<qrcode>','</qrcode>');
            DefinePosicao(1);
            iRet := ImpressaoQRCode(sAuxQR,4,2);
         end
         else If Pos(aArTags[1],sTextoEnv) > 0 then //aArTags[1] == <b>
         begin
            cAuxText := StringReplace(oTexto.Strings[nPos],'</b>','',[rfReplaceAll]);
            cAuxText := StringReplace(cAuxText,'<b>','',[rfReplaceAll]);
            iRet := ImpressaoTexto(cAuxText,1,9,0);
         end
         else If (Pos(aArTags[12],sTextoEnv) = 0) and (Trim(sTextoEnv) <> '') then
            iRet := ImpressaoTexto(oTexto.Strings[nPos],1,1,0)
         else If Trim(sTextoEnv) = '' then
            iRet := AvancaPapel(1);

         //Acionar a guilhotina caso tenha a tag <gui>
         If bCorte then
         begin
            iRet := CorteTotal(5);
            bCorte := False;
         end;

      End;
      GravaLog('Impressora Nao Fiscal <- ImpressaoCupomNF :' + IntToStr(iRet));
    end
    else
    begin
      GravaLog('Impressora Nao Fiscal -> ImpressaoTexto : ' + Texto);
      For nPos := 0 to Pred(oTexto.Count) do
         iRet := ImpressaoTexto(oTexto.Strings[nPos],0,0,0);
      GravaLog('Impressora Nao Fiscal <- ImpressaoTexto :' + IntToStr(iRet));
    end;
  end;

  If iRet >= 0
  then Result := '0|'
  else Result := '1|';
end;

end;

//----------------------------------------------------------------------------
function TImpNfE1DLL.ImpBitMap( Arquivo:String ):String;
var
  iRet, nX : Integer;
begin

iRet := VerStatus();

If iRet = 0 then
begin
  GravaLog('Impressora Nao Fiscal -> ImprimeBmpEspecial');
  iRet := ImprimeImagem(Arquivo);
  GravaLog('Impressora Nao Fiscal <- ImprimeBmpEspecial : ' + IntToStr(iRet));
end;

If iRet = 1
then Result := '0|'
else Result := '1|';

end;

//----------------------------------------------------------------------------
function TImpNfE1DLL.VerStatus(): Integer;
var
   iRet : Integer;
   sMsg : String;
begin
GravaLog('Impressora Nao Fiscal -> VerStatus');
iRet := StatusImpressora(5);
GravaLog('Impressora Nao Fiscal <- VerStatus : ' + IntToStr(iRet));

case iRet of
   0: sMsg := 'Impressora OK';
   2: sMsg := 'Tampa Aberta';
   4: sMsg := 'Impressora com pouco papel! Verifique';
   12:sMsg := 'Impressora SEM PAPEL';
   24:sMsg := 'Impressora ONLINE';
else
   sMsg := 'Retorno : '+ IntToStr(iRet) + ' desconhecido. Verifique manual do fabricante';
end;

If (iRet = 0) or (iRet = 24)
then Result := 0
else
   begin
      GravaLog(sMsg);
      LjMsgDlg(sMsg);
                                       
      If iRet = 5
      then Result := 1
      else Result := 0;
   end;
end;

//----------------------------------------------------------------------------
function TImpNfE1DLL.TrataTags( var Texto : String ): String;
var
   sRet,sAux,sCorrigeQrCode : String;
   nX : Integer;
begin
sRet := '';

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
  GravaLog(' Impressora Não Fiscal - Inserida a tag <lmodulo>5</lmodulo> para impressão do QRCode ');
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

//----------------------------------------------------------------------------
function TImpNfE1DLL.ExtraiTag( aText, OpenTag, CloseTag : String ) : String;
{ Retorna o texto dentro de 2 tags (open & close Tag's) }
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

//----------------------------------------------------------------------------
function TImpNfE1DLL.AbreGaveta: String;
var
  iRet : Integer;
begin

GravaLog('Impressora Nao Fiscal -> AcionarGaveta');
iRet := AbreGavetaElgin();
GravaLog('Impressora Nao Fiscal <- AcionarGaveta : ' + IntToStr(iRet));

If iRet = 0
then Result := '0|'
else Result := '1|';
end;

//----------------------------------------------------------------------------
function TImpNfE1DLL.RemoveTags( var Texto : String ): String;
var
  sRet : String;
begin
  sRet := Texto;
  sRet := StringReplace(sRet,'</ce>','',[rfReplaceAll]);
  sRet := StringReplace(sRet,'<ce>','',[rfReplaceAll]);
  sRet := StringReplace(sRet,'</c>','',[rfReplaceAll]);
  sRet := StringReplace(sRet,'<c>','',[rfReplaceAll]);

  Result := sRet;

end;

//=============================================================================
initialization
  RegistraImpressora('BEMATECH MP-4200 HS'  , TImpNfE1DLL  , 'BRA' ,'      ');
end.


