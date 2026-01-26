unit UProc01;

interface

uses
  Forms, Windows, SysUtils;

type

   //TExportDoc é uma variavel de função que funcionará como um ponteiro da função ExportWDoc da dll.
   TExportDoc = function (pServerName, pUserID, pPassword, plcObjectID, pPasta, pNomeArq: WideString) : Integer; stdcall;

   //TImportDoc é uma variavel de função que funcionará como um ponteiro da função ImportWDoc da dll.
   TImportDoc = function (pServerName, pDataBase, pUserID, pPassword, plcCliente, plcCaso, plcArqRet, plcArquivo, plcFichaWorkSite : WideString) : String; stdcall;

   function getFileSize(const FileName: string): LongInt;
   function fnCreateFile(NomeArq, Dados: String): Boolean;

   procedure ProcExp(cServidor, cUsuario, cSenha, cIDDoc, cPath, cNomeArq : String);
   procedure ProcImp(cServidor, cDataBase, cUsuario, cSenha, cCliente, cCaso, cArqRet, cArquivo, cFichaWorkSite : String);

implementation

    function ExportWDoc(pServerName, pUserID, pPassword, plcObjectID, pPasta, pNomeArq: WideString) : Integer;
             stdcall; external 'SIGAGEDW.DLL';
    function ImportWDoc(pServerName, pDataBase, pUserID, pPassword, plcCliente, plcCaso, plcArqRet, plcArquivo, plcFichaWorkSite : WideString) : String;
             stdcall; external 'SIGAGEDW.DLL';

// Manipulação do log
function getFileSize(const FileName: string): LongInt;
var
  SearchRec: TSearchRec;
  sgPath   : String;
  inRetval : Integer;
begin
  sgPath   := ExpandFileName(FileName);
  try
    inRetval := FindFirst(ExpandFileName(FileName), faAnyFile, SearchRec);
    If inRetval = 0 then
      Result := SearchRec.Size
    else
      Result := -1;
  finally
    SysUtils.FindClose(SearchRec);
  end;
end;

function fnCreateFile(NomeArq, Dados: String): Boolean;
var
  ArqLogico:TextFile;
  vlcNameNew : String;
  vlcNameHour : String;
begin
  try
    AssignFile(ArqLogico,NomeArq);
    if not FileExists(NomeArq) then
      ReWrite(ArqLogico)
    else
    begin
      // Se o tamanho do arquivo exceder 25 MB é criado outro log.
      if ( getFileSize(NomeArq)/1024 < 25600 ) then
        Append(ArqLogico)
      else
      begin
        vlcNameNew := StringReplace(StringReplace(NomeArq,'.',FormatDateTime('dd-mm-yyyy hh-mm', Now)+'.',[rfReplaceAll]),'/','-',[rfReplaceAll]);
        RenameFile(NomeArq, vlcNameNew);
        ReWrite(ArqLogico);
      end;
    end;
    Result:=True;
  except
    Result:=False;
  end;

  if Result then
  begin
    WriteLn(ArqLogico,formatdatetime('dd/mm/yyyy hh:nn:ss - ',now),Dados);
    CloseFile(ArqLogico);
  end;
end;

procedure ProcExp(cServidor, cUsuario, cSenha, cIDDoc, cPath, cNomeArq : String);
var
   mExportDoc : TExportDoc; //Macro da função ExportDoc da dll.
   nHandle    : THandle;    //Manipulador da dll.
   nResultado : Integer;
   ArqLog     : TextFile;

begin

    nResultado := 1;

    nHandle := LoadLibrary('SIGAGEDW.DLL');
{
    AssignFile(ArqLog, 'SGGED32.LOG');

    If  FileExists('SGGED32.LOG') then
        Append(ArqLog)   //Abre e adiciona os dados no fim do arquivo.
    Else
        ReWrite(ArqLog); //Abre arquivo novo.
}
    While True do
    begin
        AssignFile(ArqLog, 'SGGED32.LOG');

        If  FileExists('SGGED32.LOG') then
            Append(ArqLog)   //Abre e adiciona os dados no fim do arquivo.
        Else
            ReWrite(ArqLog); //Abre arquivo novo.

        fnCreateFile('SGGED32.LOG', 'Iniciando exportação - ' + DateToStr(Date) + ' - ' + TimeToStr(Time));
        fnCreateFile('SGGED32.LOG', 'ID: ' + cIDDoc);

        If  (nHandle = 0) then
        begin
            fnCreateFile('SGGED32.LOG', 'Problema para carregar SGGED32.DLL');
            Break;  //Finaliza caso nao consiga carregar!
        End{If};

        @mExportDoc := GetProcAddress(nHandle, 'ExportWDoc');

       If  (@mExportDoc = nil) then begin
           fnCreateFile('SGGED32.LOG', 'Problema para obter a funcao ExportWDoc!');
           FreeLibrary(nHandle);
           Break; //Finaliza caso nao consiga obter a função!
       End{If};

       Try
           nResultado := mExportDoc(cServidor, cUsuario, cSenha, cIDDoc, cPath, cNomeArq);
       Except
           On e : Exception do begin
               WriteLn(ArqLog, 'Erro: ' + e.Message);
               nResultado := -1;
           End{On};
       end{Except};

       If  (nResultado = -1) then begin
          fnCreateFile('SGGED32.LOG', 'Exportação não realizada!');
           FreeLibrary(nHandle);
           Break;
       End{If};

       fnCreateFile('SGGED32.LOG', 'Exportação realizada com sucesso!');
       Break;
   End;

end;

procedure ProcImp(cServidor, cDataBase, cUsuario, cSenha, cCliente, cCaso, cArqRet, cArquivo, cFichaWorkSite : String);
var
   mImportDoc : TImportDoc; //Macro da função ImportDoc da dll.
   nHandle    : THandle;    //Manipulador da dll.
   cResultado : String;
   ArqLog     : TextFile;

begin

    cResultado := 'Erro';

    nHandle := LoadLibrary('SIGAGEDW.DLL');

    While True do begin
        fnCreateFile('SGGED32.LOG', 'Iniciando importação - ' + DateToStr(Date) + ' - ' + TimeToStr(Time));
        fnCreateFile('SGGED32.LOG', 'Arquivo: ' + cArquivo);
        fnCreateFile('SGGED32.LOG', 'cServidor: ' + cServidor +' - cDataBase: '+ cDataBase +' - cUsuario: '+ cUsuario +' - cSenha: '+ cSenha +' - cCliente: '+ cCliente +' - cCaso: '+ cCaso +' - cArqRet: '+ cArqRet +' - cArquivo: '+ cArquivo +' - cFichaWorkSite: '+ cFichaWorkSite);

        If  (nHandle = 0) then begin
            fnCreateFile('SGGED32.LOG', 'Problema para carregar SGGED32.DLL');
            Break;  //Finaliza caso nao consiga carregar!
        End{If};
        @mImportDoc := GetProcAddress(nHandle, 'ImportWDoc');

       If  (@mImportDoc = nil) then begin
           fnCreateFile('SGGED32.LOG', 'Problema para obter a funcao ImportWDoc!');
           Break; //Finaliza caso nao consiga obter a função!
       End{If};

       Try
           cResultado := mImportDoc(cServidor, cDataBase, cUsuario, cSenha, cCliente, cCaso, cArqRet, cArquivo, cFichaWorkSite);
       Except
           On e : Exception do begin
               fnCreateFile('SGGED32.LOG', 'Erro: ' + e.Message);
               cResultado := 'Erro';
           End{On};
       end{Except};

       If  (cResultado = 'Erro') then
       begin
          fnCreateFile('SGGED32.LOG', 'Importação não realizada!');

          Break;
       End{If};
       fnCreateFile('SGGED32.LOG', 'Importação realizada com sucesso!');
       Break;
   End;

end;

end.

