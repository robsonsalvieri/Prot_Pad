unit BalancaEmulador;

interface

uses
  Dialogs, BalancaMain, ImpCheqMain, Windows, SysUtils, classes, LojxFun,
  IniFiles, Forms;

Type
  TBalEmul = Class( TBalanca )
  Public
    function Abrir( sPorta:AnsiString ):AnsiString; override;
    function Fechar( sPorta:AnsiString ):AnsiString; override;
    function PegaPeso( ):AnsiString; override;
  End;

Function OpenEmulador( sPorta:AnsiString ):AnsiString;
Function CloseToledo : AnsiString;

//------------------------------------------------------------------------------
implementation

Var
  iInteiros   : Integer; //Numero de Inteiros do Peso
  iDecimais   : Integer; //Numero de Decimais do Peso

Const
  {
  Se alterar esse nome deve alterar o Exe que gera o arquivo
  como se fosse a interface da balança 
  }
  sFile : AnsiString = 'emuladorpeso.txt';

//------------------------------------------------------------------------------
Function OpenEmulador( sPorta:AnsiString ) : AnsiString;
var
  bRet : Boolean;
  fArquivo : TIniFile;
  sMode,sPath : AnsiString;
begin
  GravaLog(' OpenEmulador -> Porta:' + sPorta);
  Result:= '0';
  bRet  := True;
  sPath := ExtractFilePath(Application.ExeName);

  // Capturo do SIGALOJA.INI os dados para abertura de porta
  // [BALANCA]
  // Mode = 0 ou 1 (desligado ou ligado)
  // Inteiro = 3
  // Decimais = 3
  try
    GravaLog(' Balanca -> Leitura do arquivo SIGALOJA.INI no caminho [' + sPath + ']');
    fArquivo:= TIniFile.Create(sPath+'SIGALOJA.INI');
    sMode   := fArquivo.ReadString('balanca', 'mode', '1');
    iInteiros := StrToInt(fArquivo.ReadString('balanca', 'Inteiro', '3'));
    iDecimais := StrToInt(fArquivo.ReadString('balanca', 'Decimais', '3'));
    fArquivo.Free;
  except
    MsgStop('Não foi possível ler o arquivo SIGALOJA.INI / Vide configuração da Sessão [BALANCA]');
    GravaLog('Não foi possível ler o arquivo SIGALOJA.INI / Vide configuração da Sessão [BALANCA]');
    bRet := False;
  end;

  If bRet AND (sPorta = '') then
  begin
    ShowMessage(' Porta não configurada no cadastro de Estação (LOJA121) - Verifique! ');
    GravaLog(' Porta não configurada no cadastro de Estação (LOJA121) - Verifique! ');
    Result := '1';
    bRet := False;
  end;

  If bRet AND (sMode = '0') then
  begin
    ShowMessage('a balanca esta setada como desligada - [ no arquivo SIGALOJA.INI - Sessão Balanca ] ');
    GravaLog('a balanca esta setada como desligada - [ no arquivo SIGALOJA.INI - Sessão Balanca ] ');
    Result := '1';
    bRet := False;
  end;

  If bRet then
  begin
    GravaLog('Emulador de Balança conectado com sucesso');
    Result := '0';
  end;
End;

//------------------------------------------------------------------------------
Function CloseToledo : AnsiString;
begin
  GravaLog(' Emulador Balanca Fechado ->');
  Result := '0';
end;

//------------------------------------------------------------------------------
Function TBalEmul.Abrir( sPorta:AnsiString ):AnsiString;
Begin
  Result := OpenEmulador(sPorta);
End;

//------------------------------------------------------------------------------
function TBalEmul.Fechar( sPorta:AnsiString ):AnsiString;
begin
  Result := CloseToledo;
end;

//------------------------------------------------------------------------------
Function TBalEmul.PegaPeso():AnsiString;
Var
  sPeso: AnsiString;
  iPos : Integer;
  bRet: Boolean;
  iPeso : currency;
  ListaPeso : TStringList;
Begin
  GravaLog(' Função PegaPeso - Inicio ');
  bRet := True;
  ListaPeso := TStringList.Create();
  ListaPeso.Clear;

  {
  o arquivo será convencionado da seguinte forma:
  Respeitando as chaves Inteiro e Decimais do arquivo SIGALOJA.INI
  Usando o separador '.' (ponto)
  }
  If FileExists(sFile) then
  begin
    ListaPeso.LoadFromFile(sFile);
    sPeso := ListaPeso.Strings[0];
    iPos := Pos('.',sPeso);
    If iPos = 0
    then begin
           bRet := False;
           ShowMessage('Arquivo de Peso Fora da Configuração Padrão - '+
                        'Insira o peso utilizando o utilitário da Balança TOTVS');
           GravaLog('Arquivo de Peso Fora da Configuração Padrão - '+
                    'Insira o peso utilizando o utilitário da Balança TOTVS');
         end;

    If bRet then
    begin
      Try
        iPeso := StrToFloat(sPeso);
        GravaLog(' Emulador Balanca  -> Peso Capturado:' + sPeso);
      Except
        ShowMessage('Arquivo de Peso Fora da Configuração Padrão - '+
            'Insira o peso utilizando o utilitário da Balança TOTVS');
        GravaLog('Arquivo de Peso Fora da Configuração Padrão - '+
            'Insira o peso utilizando o utilitário da Balança TOTVS');
        bRet := False;
      End;
    end;
  end
  else
  begin
    bRet := False;
    ShowMessage('Peso não capturado - Arquivo de peso não encontrado : emuladorpeso.txt');
    GravaLog('Peso não capturado - Arquivo de peso não encontrado : emuladorpeso.txt');
  end;

  If bRet Then
  Begin
    Result := '0|'+ sPeso;
  End
  Else
  Begin
    Result := '1|';
  End;

  GravaLog(' Função PegaPeso - Fim - Retorno: ' + Result);
end;

initialization
  RegistraBalanca( 'Balanca Emulador', TBalEmul, 'BRA' );

end.
