program TOTVSPDV11;

uses
  SysUtils,
  Windows,
  Dialogs,
  TelaParametros in 'TelaParametros.pas' {frmParametros},
  Genericos in 'Genericos.pas',
  Imagens in 'Imagens.pas' {Form1};

{$R *.RES}
                                
var
  sCommand       : String;
  sParametro     : String;
  sModulo   , sAmbiente, sTcp : String;
  nCont          : Integer;
  sParams        : String;

begin
  sCommand   := '';
  sParametro := '';
  sModulo    := '';
  sAmbiente  := '';
  sTcp       := '';
  nCont      := 0;
  sParams    := '';

    sCommand := Executavel;

    For nCont := 1 To ParamCount Do
    begin
       sParametro := UpperCase( ParamStr(nCont) );

       //Modulo --
       If Pos('-P=SIGA', sParametro) > 0 Then
          sModulo := Copy( sParametro, 4, Length(sParametro) )

       //Ambiente
       Else If Pos('-E=', sParametro) > 0 Then
          sAmbiente := Copy( sParametro, 4, Length(sParametro) )

       //TCP
       Else If Pos('-C=', sParametro) > 0 Then
          sTcp := Copy( sParametro, 4, Length(sParametro) )

       //Outros Parametros
       Else
          sParams := sParams + '|' + sParametro
    end;

    //Executa Modulo
    If (sModulo <> '') and (sAmbiente <> '') and (sTcp <> '') Then
        ExecClient(sCommand, Funcao, sModulo, Valid, sParams, sAmbiente, sTcp)

    //Abrir Tela para Seleção dos Parametros
    Else
        ShowMessage('Para acesso ao PAF-ECF, configure os parâmetros do atalho SIGAPAF11 com o conteudo: -P=SIGAFRT ou -P=SIGALOJA -E=<ambiente> -C=<TCP> -m -A= -A=<estação>.')

//    begin
//        frmParametros := TfrmParametros.Create(Form1);
//        frmParametros.ShowModal;
//    end;

end.
