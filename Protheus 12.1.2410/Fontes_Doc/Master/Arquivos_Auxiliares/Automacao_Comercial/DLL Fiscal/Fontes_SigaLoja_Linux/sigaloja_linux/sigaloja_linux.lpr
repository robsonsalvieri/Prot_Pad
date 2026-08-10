library sigaloja_linux;

{$mode objfpc}{$H+}

{$R *.res}

uses
  Classes, Unix, SysUtils, StrUtils, dynlibs, BaseUnix, ctypes, unixtype, dl, e1_impressora, funcoesGenericas;

var
  libE1Impressora: Pointer;
  Continua: Boolean;

procedure CarregaSoFabricante;
begin
  libE1Impressora:= dlopen(PChar(ExtractFilePath(ParamStr(0)) + 'libE1_Impressora.so'),RTLD_NOW or RTLD_GLOBAL);
  if libE1Impressora = nil then
  begin
    fpSystem('zenity --info --text="Nao foi possivel carregar a biblioteca libE1_Impressora.so. Verifique se a biblioteca encontra-se dentro do diretorio web-agent!"');
    GravaLog('Nao foi possivel carregar a biblioteca libE1_Impressora.so. Verifique se a biblioteca encontra-se dentro do diretorio web-agent!');
    Continua := false;
  end
  else
  begin
    GravaLog('Biblioteca libE1_Impressora.so carregada sucesso - ' + ExtractFilePath(ParamStr(0)));
    Continua := true;
  end;
end;

function ExecInClientDLL(aFuncID: integer; aParams, aBuff: PAnsiChar; Buff_Size: integer): Integer; export; cdecl;
var
  nRet: Integer;
  sSeparador, sString: string;
  nPos: integer;
  Lista: TStringList;
begin
  if Trim(GravaLogAtivo) = '' then
    GravaLogAtivo := Trim(LerArquivoIni('logdll','log'));

  GravaLog('**** INICIO CHAMADA DA BIBLIOTECA ****');
  GravaLog('Versao: 22');
  GravaLog('aFuncID: ' + IntToStr(aFuncId));
  GravaLog('aParams: ' + aParams);
  GravaLog('aBuff: ' + aBuff);
  GravaLog('Buff_Size: ' + IntToStr(Buff_Size));

  CarregaSoFabricante();

  if Continua then
  begin

    Lista := TStringList.Create;


    if aFuncID = 133 then
      sSeparador:='\'
    else
      sSeparador:=',';

    sString := copy(aParams, 1, Length(aParams));
    While True do
    begin
      nPos := Pos(sSeparador, sString);
      if nPos = 0 then
      begin
        Lista.add(sString);
        Break;
      end;
      Lista.add(copy(sString, 1, nPos - 1));
      sString:= copy(sString, nPos + 1, Length(sString));
    end;

    try

      try
        case aFuncID of
          999:begin
                StrLCopy(aBuff, PChar(GetVersaoDLL()), Buff_Size - 1);
                nRet := 0;
              end;
          2,55,63,67,72,79,88:
              begin
                //Lista de equipamentos que não serão mais utilizados
                StrLCopy(aBuff, PChar(''), Buff_Size - 1);
                nRet := 0;
              end;
          50: begin
                //Lista dos pinpad
                StrLCopy(aBuff, PChar(''), Buff_Size - 1);
                nRet := 0;
              end;
          59: begin
                //Lista das gavetas
                StrLCopy(aBuff, PChar(''), Buff_Size - 1);
                nRet := 0;
              end;
          130: begin
                 //Lista impressoras nao fiscais
                 StrLCopy(aBuff, PChar('"' + 'ELGIN I9",BRA,"' + '","' + 'BEMATECH MP-4200 HS",BRA,"' + '","' + 'BEMATECH MP-4200 TH",BRA,"' + '","' + 'BEMATECH MP-4200 ADV",BRA,"' + '","' + 'ELGIN I8",BRA,"' + '"'), Buff_Size - 1);
                 nRet := 0;
               end;
          131: nRet := AbreConexaoImpressora(libE1Impressora, StrToInt(Lista[0]), Lista[1], Lista[2], StrToInt(Lista[3]));
          132: nRet := FechaConexaoImpressora(libE1Impressora);
          133: nRet := ImpressaoTexto(libE1Impressora, Lista[0], StrToInt(Lista[1]), StrToInt(Lista[2]), StrToInt(Lista[3]));
          134: nRet := ImprimeImagem(libE1Impressora, Lista[0]);
          135: nRet := ImpressaoCodigoBarras(libE1Impressora, StrToInt(Lista[0]), Lista[1], StrToInt(Lista[2]), StrToInt(Lista[3]), StrToInt(Lista[4]));
          62,137: nRet := AbreGavetaElgin(libE1Impressora);
        else
          begin
            fpSystem('zenity --info --text="' + 'Id não implementado: ' + IntToStr(aFuncID) + '"');
            GravaLog('Id não implementado: ' + IntToStr(aFuncID));
            Result := -1;
          end;
        end;

        Result := nRet;

      except
        on E: Exception do
        begin
          fpSystem('zenity --info --text="' + 'Erro na execução da funcao da .so da impressora - Erro: ' + E.Message + '"');
          GravaLog('Erro na execucao da funcao da .so da impressora - Erro: ' + E.Message);
          Result := -1;
        end;
      end;

    finally
      Lista.Free;
      GravaLog('Retorno aBuff: ' + aBuff);
      GravaLog('Retorno: ' + IntToStr(Result));
      GravaLog('**** FINAL CHAMADA DA BIBLIOTECA ****');
      GravaLog('*************************************');
    end;
  end
  else
  begin
    Result := -1;
  end;

end;

exports
  ExecInClientDLL;


end.

