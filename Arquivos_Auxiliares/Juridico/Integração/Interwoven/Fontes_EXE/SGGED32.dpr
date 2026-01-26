program SGGED32;

uses
  Forms, Windows,
  UProc01 in 'UProc01.pas';

{$R *.res}

var
    cTipo          : String; {I - Importacao / E - Exportacao}
    cServidor      : String; {I/E}
    cDataBase      : String; {I}
    cUsuario       : String; {I/E}
    cSenha         : String; {I/E}
    cCliente       : String; {I - Cliente e Caso definem a pasta dentro do worksite}
    cCaso          : String; {I}
    cIDDoc         : String; {E}
    cPath          : String; {E}
    cNomeArq       : String; {E}
    cArqRet        : String; {I - Pasta + Arquivo}
    cArquivo       : String; {I - Pasta + Arquivo}
    cFichaWorkSite : String; {I}
begin

    cTipo     := ParamStr(01);

    If  (cTipo = 'I') then begin {Importacao}

        cServidor      := ParamStr(02);
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

        cServidor := ParamStr(02);
        cUsuario  := ParamStr(03);
        cSenha    := ParamStr(04);
        cIDDoc    := ParamStr(05);
        cPath     := ParamStr(06);
        cNomeArq  := ParamStr(07);

        ProcExp(cServidor, cUsuario, cSenha, cIDDoc, cPath, cNomeArq);

    end{else};

end.
