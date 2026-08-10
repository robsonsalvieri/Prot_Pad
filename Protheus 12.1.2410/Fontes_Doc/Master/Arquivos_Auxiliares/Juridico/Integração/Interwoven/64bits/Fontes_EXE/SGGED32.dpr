program SGGED32;

uses
  Forms, Windows, Dialogs,
  UProc01 in 'UProc01.pas';

{$R *.res}

var
    cTipo          : WideString; {I - Importacao / E - Exportacao}
    cServidor      : WideString; {I/E}
    cDataBase      : WideString; {I}
    cUsuario       : WideString; {I/E}
    cSenha         : WideString; {I/E}
    cCliente       : WideString; {I - Cliente e Caso definem a pasta dentro do worksite}
    cCaso          : WideString; {I}
    cIDDoc         : WideString; {E}
    cPath          : WideString; {E}
    cNomeArq       : WideString; {E}
    cArqRet        : WideString; {I - Pasta + Arquivo}
    cArquivo       : WideString; {I - Pasta + Arquivo}
    cFichaWorkSite : WideString; {I}
begin

  showmessage('chamou o executável ds DLL');

    cTipo     := ParamStr(01);

    If  (cTipo = 'I') then begin {Importacao}

    showmessage( 'cServidor antes: '+ParamStr(02));
        cServidor      := WideString(ParamStr(02));
    showmessage( 'cServidor depois: '+cServidor);
        cDataBase      := ParamStr(03);
        cUsuario       := ParamStr(04);
        cSenha         := ParamStr(05);
        cCliente       := ParamStr(06);
        cCaso          := ParamStr(07);
        cArqRet        := ParamStr(08);
        cArquivo       := ParamStr(09);
        cFichaWorkSite := ParamStr(10);

        ProcImp(cServidor, cDataBase, cUsuario, cSenha, cCliente, cCaso, cArqRet, cArquivo, cFichaWorkSite);

    end{If} else {Exportacao} begin

//      Application.MessageBox(PChar('Parametros: ' + cServidor + ' - ' + cUsuario + ' - ' + cSenha + ' - ' + cIDDoc + ' - ' + cPath + ' - ' + cNomeArq),'Mensagem ao Usuário', mb_OK + mb_DefButton1);

    showmessage( 'cServidor antes: '+ParamStr(02));
        cServidor      := WideString(ParamStr(02));
    showmessage( 'cServidor depois: '+cServidor);
        cUsuario  := ParamStr(03);
        cSenha    := ParamStr(04);
        cIDDoc    := ParamStr(05);
        cPath     := ParamStr(06);
        cNomeArq  := ParamStr(07);

        ProcExp(cServidor, cUsuario, cSenha, cIDDoc, cPath, cNomeArq);

    end{else};

end.
