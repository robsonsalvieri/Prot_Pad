library SIGAGEDW;

uses
  SysUtils,
  StrUtils,
  Dialogs,
  ActiveX,
  Variants,
  Forms,
  Messages,
  IIntegrationDlg_TLB in 'IIntegrationDlg_TLB.pas',
  IMANEXTLib_TLB in 'IMANEXTLib_TLB.pas',
  Code64 in 'Code64.pas',
  IManage_TLB in 'IManage_TLB.pas';

{$R *.res}

type
    { Evento de inicialização do objeto ImportCmd para atualziação dos campos de importação. }
    TEventTarget=class(TObject)
    public
        procedure pOnInitDialog(Sender: TObject; var pMyInterface: OleVariant);
    end;

    TDuploArray = array of array of string;

var
  vIManDMS     : IManDMS;
  vIManSession : IManSession;
  aDoc         : Array of Array of String;
  ArqLog       : TextFile;
  aParametros  : TDuploArray;


{
LoginGed        - Utilizado para fazer Login no GED
LogoutGed       - Utilizado para fazer Logout no GED
OpenDoc         - Utilizado para abrir um documento que está no GED. É necessário estar logado ao GED
ImportDoc       - Utilizado para importar um documento para o GED. É necessário estar logado ao GED
ImportWDoc      - Utilizado para importar um documento para o GED via SmartClient HTML. É necessário estar logado ao GED
AttachDoc       - Utilizada para anexar um documento que ja esta no Worksite
ExecInClientDLL - Rotina pública da biblioteca para interface com outras aplicações (Protheus).
                  Através destas rotina se tem acesso as demais por meio de parametros
}

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

function fnCreateFile(NomeArq, Dados: String; plbLog : Boolean = True ): Boolean;
var
  ArqLogico   : TextFile;
  vlcNameNew  : String;
  vlcNameHour : String;
  vlcData     : String;
begin
  vlcData :='';
  if plbLog then
      vlcData := formatdatetime('dd-mm-yyyy hh-nn-ss - ',now);
      
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
        vlcNameNew := StringReplace(StringReplace(NomeArq,'.',vlcData +'.',[rfReplaceAll]),'/','-',[rfReplaceAll]);
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
    WriteLn(ArqLogico,vlcData ,Dados);
    CloseFile(ArqLogico);
  end;
end;

function ReplaceSTR(Valor: string): String;
Var
  i: Integer;
begin
  if Valor <> ' ' then
  begin
    for i := 0 to Length(Valor) do
    begin
      if (Valor[i]= '''') or (Valor[i]= '"') or (Valor[i]= ';') then
      begin
        Valor[i]:=' ';
      end
    end;
  end;
  Result := valor;
end;

function fnSubString(plcStr: String; plcParte: Integer; plcSeparador: String): String;
var
  lp0, sln, CurrN: Integer;
  EmSep, PrimEncontrado: Boolean;
begin
  Result := '';
  CurrN  := 0;
  EmSep  := False;
  PrimEncontrado := False;
  sln := Length(plcStr);

  For lp0 := 1 To sln Do
  Begin
    If Pos(plcStr[lp0],plcSeparador) > 0 Then
    Begin
      If Not EmSep Then
      Begin
        If PrimEncontrado Then
          inc(CurrN);
      End;

      EmSep := True;

      If CurrN > plcParte Then
        break;
     End
     Else
     Begin
       EmSep := False;
       PrimEncontrado := True;

       If CurrN = plcParte Then
         Result := Result + plcStr[lp0];
    End;
  End;
end;

{
Utilizado para fazer Login no GED
Parametros
pServerName - Nome do servidor
pTrustedLogin - Forma de Login (True utiliza TrustedLogin e False abre tela pedindo usuário/senha para autenticação)
Retorno
Valor booleano (True conseguiu fazer Login com sucesso e False não conseguiu fazer login)
}
function LoginGed(pServerName: PAnsiChar;pTrustedLogin:Boolean=False): WordBool;
var
  vIManSessions: IManSessions;
  vConnected : WordBool;
  vFormLogin : TLoginDlg;
begin
  If Not(Assigned(vIManDMS)) Then
  Begin
    CoInitialize(nil);
    vIManDMS := CoManDMS.Create;
    IManDMS(vIManDMS).Get_Sessions(vIManSessions);
    vIManSessions.Add(trim(WideString(AnsiString(pServerName))),vIManSession);
  End;
  vFormLogin := TLoginDlg.Create(nil);
  try
    vIManSession.Get_Connected(vConnected);
    If Not(vConnected) Then
    begin
      if pTrustedLogin then
        vIManSession.TrustedLogin
      else
      begin
        vFormLogin.Show(0);
        if vFormLogin.TrustedLogin then
          vIManSession.TrustedLogin
        else
        begin
          vIManSession.Login(vFormLogin.UserID,vFormLogin.Password);
        end;
      end;
    end;
  finally
    FreeAndNil(vFormLogin);
  end;
  vIManSession.Get_Connected(Result);
end;

{
Utilizado para fazer Logout no GED
Parametros
Nenhum
Retorno
Nenhum
}
procedure LogoutGed;
var
  vConnected : WordBool;
begin
  if Assigned(vIManSession) and Assigned(vIManDMS) then
  begin
    vIManSession.Get_Connected(vConnected);
    If vConnected Then
      vIManSession.Logout;
    vIManSession := nil;
    vIManDMS.Close;
    vIManDMS := nil;
    CoUninitialize;
  end;
end;

{
Utilizado para abrir um documento que está no GED (é necessário fazer Login antes)
Parametros
plcObjectID - URL do documento que deve ser aberto
Retorno
Nenhum
}
procedure OpenDoc(plcObjectID: String);
var
  vArrayDocs: Array Of IDispatch;
  vContextItems: TContextItems;
  objOpenCmd: TOpenCmd;
  vConnected : WordBool;
begin
  vIManSession.Get_Connected(vConnected);
  If vConnected Then
  begin
    SetLength(vArrayDocs,1);
    vIManDMS.GetObjectBySID(plcObjectID,vArrayDocs[0]);
    vContextItems := TContextItems.Create(Nil);
    vContextItems.Add('ParentWindow',0);
    vContextItems.Add('SelectedNRTDocuments',vArrayDocs);
    objOpenCmd := TOpenCmd.Create(Nil);
    objOpenCmd.Initialize(vContextItems.DefaultInterface);
    objOpenCmd.Execute;
  end
  else
    Dialogs.MessageDlg('Erro na conexão com a base de documentos.',mtInformation,[MBOK],0);
end;

function FichaWorkSite(cFichaWorkSite: WideString; var cClasse: WideString; var aParametros : TDuploArray): Boolean;
var
   nPos1      : Integer;    //Posicao string principal - '|-|'
   nPos2      : Integer;    //Posicao string secundaria - '|+|'
   cAux1      : WideString; //Copia e corte da string principal
   cAux2      : WideString; //String secundaria parte da string principal
   cAux3      : WideString; //String terciaria parte da string secundaria
   lContinua1 : Boolean;    //Loop principal
   lContinua2 : Boolean;    //Loop secundario
   nTam1      : Integer;    //Tamanho da Matriz principal
   nTam2      : Integer;    //Tamanho da Matriz secundaria
   lClassOk   : Boolean;    //Ficara verdadeiro ao encontrar NRCLASS
begin

   Result     := False;

   cClasse    := '';    //Quando encontrar NRCLASS irá atribuir o valor a esta variavel,...
   lClassOk   := False; //... valor utilizado para localizar a pasta na area de trabalho.

   cAux1      := cFichaWorkSite;

   lContinua1 := True;

   nTam1      := 0;

   While lContinua1 do begin

       nPos1 := Pos('||', String(cAux1));

       If  (nPos1 > 0) then begin
           cAux2      := LeftStr(cAux1, nPos1-1);
           cAux1      := MidStr(cAux1, nPos1+2, Length(cAux1));
       End{if} Else begin
           cAux2      := cAux1;
           cAux1      := '';
           lContinua1 := False;
       End{Else};

       If  (Trim(cAux2)='') then
        Break;

       lContinua2 := True;
       Inc(nTam1);
       SetLength(aParametros, nTam1);
       nTam2  := 0;
       While lContinua2 do
       begin
           nPos2 := Pos('!!', String(cAux2));

           If  (nPos2 > 0) then begin
               cAux3      := LeftStr(cAux2, nPos2-1);
               cAux2      := MidStr(cAux2, nPos2+2, Length(cAux2));
           End{if} Else begin
               cAux3      := cAux2;
               cAux2      := '';
               lContinua2 := False;
           End{Else};

           Inc(nTam2);
           SetLength(aParametros[nTam1-1], nTam2);
           aParametros[nTam1-1,nTam2-1] := cAux3;
           Result := True;

           If  AnsiSameText(cAux3, 'NRCLASS') then
             lClassOk := True;

       End{While};

       If  lClassOk And (Trim(cClasse)='') then begin
           cClasse := cAux3;  //Obtem a classe para localizar a pasta na area de trabalho.
       End{If};

   End{While};

end;

{
Utilizado para importar um documento para o GED (é necessário fazer Login antes)
Parametros
plcParams - URL do documento que deve ser importado (nome do arquivo com o path) ?? Cliente ?? Caso ?? DataBase ?? FichaWorkSite
Retorno
Valor String (PCHAR) com a URL do documento importado
}
function ImportDoc(plcParams: PAnsiChar): PAnsiChar;
var
  StrData:Longword absolute plcParams; //make StrData share B's memory so it
//also holds the address of the first
//character in the string
  StrDataSizePtr:^Longword; //pointer to 4-byte memory size--later,
//we will make it point to the BSTR
//string size location
  pImportCmd    : TImportCmd;
  pContextItems : TContextItems;
  vConnected    : WordBool;
  vNumber       : Integer;
  vNRTDocument  : OleVariant;
  vlcArquivo, vlcCliente, vlcCaso, vlcDataBase, vlcFichaWorkSite : String;
  vObjectID, vDescription, vExtension, vRetorno: String;

  {Variáveis para criar os parâmetros da tela}
  aDataBases         : IManDataBases;
  aDatabase          : IManDataBase;
  cDataBase          : WideString;
  cUsuario           : WideString;
  cPropValor         : WideString;
  cClasse            : WideString;
  cTipo              : WideString;
  cPasta             : WideString;
  nPastas            : Integer;
  nA                 : Integer;
  nProps             : Integer;
  vIManFolders       : IManFolders;
  vProfileParameters : IManProfileSearchParameters;
  vProfileParameter  : IManProfileSearchParameter;
  vSearchParameters  : IManWorkSpaceSearchParameters;
  vAllDataBaseNames  : IManStrings;
  vIManFolder        : IManFolder;
  vIManSubFolders    : IManFolders;
  vIManSubFolder     : IManFolder;
  vPropriedades      : IManAdditionalProperties;
  vPropriedade       : IManAdditionalProperty;
  oTipo              : IManDocumentType;
  cPropNome          : WideString;
  nProp, nPropIndex  : Integer;
begin
  Result := 'C';
  vIManSession.Get_Connected(vConnected);
  vIManSession.Get_UserID(cUsuario);

  If vConnected Then
  Begin
    Try
      Try

        vlcArquivo       := fnSubString(plcParams, 0, '??');
        vlcCliente       := fnSubString(plcParams, 1, '??');
        vlcCaso          := fnSubString(plcParams, 2, '??');
        vlcDataBase      := fnSubString(plcParams, 3, '??');
        vlcFichaWorkSite := fnSubString(plcParams, 4, '??');

        fnCreateFile('SIGAGEDW.LOG', 'Iniciando importação - ' + DateToStr(Date) + ' - ' + TimeToStr(Time));
        fnCreateFile('SIGAGEDW.LOG', 'Arquivo: ' + vlcArquivo);

        If ( (vlcCliente <> '') and (vlcCaso <> '') and (vlcDataBase <> '') and (vlcFichaWorkSite <> '') ) Then
        Begin
          If (Not FichaWorkSite(vlcFichaWorkSite, cClasse, aParametros)) Then
          Begin
            ShowMessage('Problema para obter os atributos do parametro! Cliente: ' + Trim(vlcCliente) + ' Caso: ' + vlcCaso);
          End;

          { Parâmetros da Tela }
          vAllDataBaseNames := CoManStrings.Create;
          vAllDataBaseNames.Add(vlcDataBase);
          vIManSession.Get_Databases(aDataBases);
          aDataBases.ItemByName(vlcDataBase,aDatabase);
          aDatabase.Get_Name(cDataBase);

          //*** Prepara vSearchParameters para receber os valores de filtragem ***
          IManDMS(vIManDMS).CreateProfileSearchParameters(vProfileParameters);
          vProfileParameters.Add(imProfileCustom1, vlcCliente, vProfileParameter);
          vProfileParameters.Add(imProfileCustom2, vlcCaso   , vProfileParameter);

          //*** Prepara vSearchParameters para receber os valores de filtragem da WorkArea ***
          IManDMS(vIManDMS).CreateWorkSpaceSearchParameters(vSearchParameters);
          vIManSession.SearchWorkspaces(vAllDataBaseNames, vProfileParameters, vSearchParameters, vIManFolders);
          vIManFolders.Get_Count(nPastas);

          If (nPastas <= 0) Then
          Begin
            ShowMessage('Nenhuma pasta encontrada com este cliente e caso! Cliente: ' + Trim(vlcCliente) + ' Caso: ' + vlcCaso);
          End
          Else
          Begin
            vIManFolders.ItemByIndex(1,vIManFolder);
            vIManFolder.Get_Name(cPasta);
            vIManFolder.Get_SubFolders(vIManSubFolders);
            vIManSubFolders.Get_Count(nPastas);

            //Procura a pasta dentro da area de trabalho através da classe
            For nA := 1 To nPastas Do
            Begin
              vIManSubFolders.ItemByIndex(nA, vIManSubFolder);
              vIManSubFolder.Get_Name(cPasta);
              vIManSubFolder.Get_AdditionalProperties(vPropriedades);
              vPropriedades.Get_Count(nProps);

              For nProp := 1 to nProps do
              begin
                vPropriedades.ItemByIndex(nProp, vPropriedade);
                vPropriedade.Get_Name(cPropNome);
                vPropriedade.Get_Value(cPropValor);

                if cPropNome = 'iMan___8' then
                  nPropIndex := nProp;
              end;
              nProp := 0;
              vPropriedades.ItemByIndex(nPropIndex, vPropriedade);
              vPropriedade.Get_Value(cPropValor);

              {  PROPRIEDADES DA PASTA
                 Pasta..: Ata de Reunião
                 nB.: 1
                 Nome..: iMan___8
                 Valor.: 12        => Classe
                 nB.: 2
                 Nome..: iMan___25
                 Valor.: 618       => Cliente
                 nB.: 3
                 Nome..: iMan___26
                 Valor.: 520       => Caso
              }

              If (cPropValor = cClasse) Then
                Break; //Pasta selecionada
            End;
          End;

          { Fim Parâmetros da Tela }

          pContextItems := TContextItems.Create(nil);
          pContextItems.Add('ParentWindow',0);

          If vIManSubFolder <> nil Then
            pContextItems.Add('IManDestinationObject'  , vIManSubFolder)
          Else
            pContextItems.Add('IManDestinationObject'  , vIManSession  );

          pContextItems.Add('IManExt.Import.FileName'  , vlcArquivo    );
          pContextItems.Add('IManExt.Import.DocAuthor' , cUsuario      );

        End
        Else
        Begin
          pContextItems := TContextItems.Create(nil);
          pContextItems.Add('ParentWindow',0);
          pContextItems.Add('IManDestinationObject'    , vIManSession );
          pContextItems.Add('IManExt.Import.FileName'  , vlcArquivo   );
          pContextItems.Add('IManExt.Import.DocAuthor' , cUsuario     );
        End;

        pImportCmd := TImportCmd.Create(nil);
        pImportCmd.Initialize(pContextItems.DefaultInterface);
        pImportCmd.Update;
        pImportCmd.Execute;

        //Resetar ArqLog pois se perde depois do pImportCmd.Execute;

        If pContextItems.Item('IManExt.Refresh') Then
        Begin
          vNRTDocument := pContextItems.Item('ImportedDocument');
          vObjectID    := vNRTDocument.ID;
          vDescription := ReplaceSTR(vNRTDocument.Description);
          vExtension   := vNRTDocument.Extension;
          vNumber      := vNRTDocument.Number;
          vRetorno     := vObjectID+' '+IntToStr(vNumber)+' '+vExtension+' '+vDescription;

          fnCreateFile('SIGAGEDW.LOG', 'Resultato: ObjetoID - ' + vObjectID +
                                    ' / Número - ' + IntToStr(vNumber) +
                                    ' / Extensão - ' + vExtension +
                                    ' / Descrição - ' + vDescription);


          StrPLCopy(plcParams,vRetorno, Length(vRetorno)); //Copy tmpStr to B

          StrDataSizePtr:=Ptr(StrData-4); //point string size location
          //which starts 4 bytes before
          //the first char in the string
          Result := PAnsiChar(vRetorno);

        End;
      Except
        On e: Exception Do
        Begin
          ShowMessage('Erro: ' + e.Message);
          fnCreateFile('SIGAGEDW.LOG', 'Erro ' + e.Message);
          Exit;
        ENd;
      End;
    Finally
      FreeAndNil(pContextItems);
      FreeAndNil(pImportCmd);
    End;
  End
  Else
    ShowMessage('Erro na conexão com a base de documentos.');
end;

{
Funcao utilizada para anexar um documento que ja esta no Worksite
Parametros
}

function AttachDoc(pcParametros: PAnsiChar): PAnsiChar;
var
  StrData:Longword absolute pcParametros; //make StrData share B's memory so it
//also holds the address of the first
//character in the string
  StrDataSizePtr:^Longword; //pointer to 4-byte memory size--later,
//we will make it point to the BSTR
//string size location
  vConnected: WordBool;
  vDocAttachDlg: TDocOpenDlg;
  vCommands: Variant;
  viManSrchParams: iManProfileSearchParameters;
  viManSrchParam: iManProfileSearchParameter;
  vArrayDocs: Array Of NRTDocument;
  vObjectID, vDescription, vExtension: String;
  vNumber, nPos: Integer;
  vRetorno, MV_JWSPESQ, MV_JNRCCLI, cCliente, MV_JNRCCAS, cCaso, vpcParametros : String;
begin

  Result := 'C';
  vIManSession.Get_Connected(vConnected);
  MV_JWSPESQ := '';
  MV_JNRCCLI := '';
  MV_JNRCCAS := '';
  if vConnected then
  begin
    vDocAttachDlg := TDocOpenDlg.Create(nil);
    try
      vDocAttachDlg.NRTDMS := IDispatch(vIManDMS);
      vCommands := VarArrayCreate([0,1], varOleStr);
      vCommands[0] := '@1@&Attach';
      vDocAttachDlg.CommandList := vCommands;
      vDocAttachDlg.SingleSel := True;
      vDocAttachDlg.CloseOnOK := False;
      vDocAttachDlg.Caption := 'Attach';

      vpcParametros := Trim(String(pcParametros));

      nPos := POS( ' ', vpcParametros );
      MV_JWSPESQ := copy( vpcParametros, 1, nPos - 1 );
      vpcParametros := copy( vpcParametros, nPos + 1, length(vpcParametros) );

      nPos := POS( ' ', vpcParametros );
      MV_JNRCCLI := copy( vpcParametros, 1, nPos - 1 );
      vpcParametros := copy( vpcParametros, nPos + 1, length(vpcParametros) );

      nPos := POS( ' ', vpcParametros );
      cCliente := copy( vpcParametros, 1, nPos - 1 );
      vpcParametros := copy( vpcParametros, nPos + 1, length(vpcParametros) );

      nPos := POS( ' ', pcParametros );
      MV_JNRCCAS := copy( pcParametros, 1, nPos - 1 );
      vpcParametros := copy( pcParametros, nPos + 1, length(pcParametros) );

      nPos := POS( ' ', vpcParametros );
      cCaso := copy( vpcParametros, nPos + 1, length(vpcParametros) );

      vIManDMS.CreateProfileSearchParameters(viManSrchParams);

      If  (trim(MV_JNRCCLI) <> '') and (trim(cCliente) <> '') then
          viManSrchParams.Add(StrToInt(MV_JNRCCLI), cCliente, viManSrchParam);

      If  (trim(MV_JNRCCAS) <> '') and (trim(cCaso) <> '') then
          viManSrchParams.Add(StrToInt(MV_JNRCCAS), cCaso, viManSrchParam);

      If  (MV_JWSPESQ = '1') then
          vDocAttachDlg.ShowContainedDocuments := IDispatch(viManSrchParams);

      vDocAttachDlg.Show(0);

      If vDocAttachDlg.CommandSelected = 1 Then
      Begin
        SetLength(vArrayDocs,1);
        vArrayDocs := vDocAttachDlg.DocumentList;
        vObjectID := NRTDocument(vArrayDocs[0]).Get_ID;
        vNumber := NRTDocument(vArrayDocs[0]).Get_Number;
        vDescription := ReplaceSTR(NRTDocument(vArrayDocs[0]).Get_Description);
        vExtension := NRTDocument(vArrayDocs[0]).Get_Extension;
        vRetorno := vObjectID + ' ' + IntToStr(vNumber) + ' ' + vExtension + ' ' + vDescription;

        StrPLCopy(pcParametros,vRetorno, Length(vRetorno)); //Copy tmpStr to B

        StrDataSizePtr:=Ptr(StrData-4); //point string size location
        //which starts 4 bytes before
        //the first char in the string

        Result := PAnsiChar(vRetorno);
      End;
    finally
      FreeAndNil(vDocAttachDlg);
    end;
  End
  Else
    Dialogs.MessageDlg('Erro na conexão com a base de documentos.',mtInformation,[mbOK],0);
end;

Function fDoc(cDescricao : String) : String;
var
   nA    : Integer;

begin

   Result := '';

   For nA := 0 to High(aDoc) do begin

       If  (aDoc[nA,0] = cDescricao) then begin
           Result := aDoc[nA,1];  //Valor do atributo
           Break;
       End{If};

   End{For nA};

end;

function fnLimpaNome(plcNome: string): string;
var
  vlcNome: string;
  i : integer;
begin
  vlcNome := plcNome;
  vlcNome := StringReplace(vlcNome,'\','-',[rfReplaceAll]);
  vlcNome := StringReplace(vlcNome,'/','-',[rfReplaceAll]);
  vlcNome := StringReplace(vlcNome,':','-',[rfReplaceAll]);
  vlcNome := StringReplace(vlcNome,'*','-',[rfReplaceAll]);
  vlcNome := StringReplace(vlcNome,'?','-',[rfReplaceAll]);
  vlcNome := StringReplace(vlcNome,'"','''',[rfReplaceAll]);
  vlcNome := StringReplace(vlcNome,'<','(',[rfReplaceAll]);
  vlcNome := StringReplace(vlcNome,'>',')',[rfReplaceAll]);
  vlcNome := StringReplace(vlcNome,'|','.',[rfReplaceAll]);
  for i:=0 to 5 do
    vlcNome := StringReplace(vlcNome,Chr(10),'',[rfReplaceAll]);

  vlcNome := StringReplace(vlcNome,Chr(13)+Chr(10),'',[rfReplaceAll]);
  Result := vlcNome;
end;

{
Autor: Antonio C Ferreira - acferreira - 09/04/2015

Utilizado para exportar um documento que está no GED (é necessário fazer Login antes)
Parametros
pServerName - Servidor do WorkSite = WORKSITE
pUserID     - Usuario para conexao
pPassword   - Senha para conexao
plcObjectID - URL do documento que deve ser exportado
pPasta      - Pasta para receber o documento exportado
Retorno
Nenhum
}
function ExportWDoc(pServerName, pUserID, pPassword, plcObjectID, pPasta, pNomeArq: WideString) : Integer; stdcall;
var
  vIManSessions     : IManSessions;
  vAllDataBaseNames : IManStrings;
  vContents         : IManContents;
  vDocument         : IManDocument;
  vConnected        : WordBool;
  vSearchParameters : IManProfileSearchParameters;
  vSearchParameter  : IManProfileSearchParameter;
  vPesq             : WordBool;
  cLocal            : WideString;
  cNome             : WideString;

  ArqLog            : TextFile;

  cMensagem         : String;
  cDocumento        : String;
  cChar1            : String;

  cUsuario          : WideString;
  cSenha            : WideString;

  nA                : Integer;  //Variação da primeira dimensao de aDoc
  nB                : Integer;  //Posicao da string cDocumento
  nPos              : Integer;  //Posicao da SubMatriz: 0 ou 1.
begin

    Result   := -1;


    cUsuario := Decode64(pUserID);   //Descriptografa da Bae64s.
    cSenha   := Decode64(pPassword);

    fnCreateFile('SIGAGEDW.LOG', 'Iniciando exportação - ' + DateToStr(Date) + ' - ' + TimeToStr(Time));
    fnCreateFile('SIGAGEDW.LOG', 'ID: ' + plcObjectID);

    try

        SetLength(aDoc, 5);  //Primeira dimensao com 5 linhas.

        nA   := 0;  //Posicao primeira dimensao da Matriz
        nPos := 0;  //Reseta para a posicao 0

        cDocumento := plcObjectID;

        //Separa os dados do link cDocumento em aDoc
        For nB := 0 to Length(cDocumento)-1 do begin
            cChar1 := cDocumento[nB];

            If  (cChar1 = #0)          then Continue
            Else If  (cChar1 = '!')         then begin
                If  (nB > 1) then Inc(nA);
                nPos := 0;  //Reseta para a posicao 0
                SetLength(aDoc[nA], 2);  //SubMatriz com 2 dimensoes
            End Else If (cChar1 = ':') then begin
                nPos := 1;  //Muda   para a posicao 1
            End Else If (cChar1 = ',') then begin
                Inc(nA);
                SetLength(aDoc[nA], 2);  //SubMatriz com 2 dimensoes
                aDoc[nA,0] := 'versao';
                nPos := 1;  //Muda   para a posicao 1
            End Else begin
                aDoc[nA,nPos] := aDoc[nA,nPos] + cChar1;  //Soma o char da string na posicao da matriz
            End;
        End{For nB};

        cMensagem := 'criar o objeto!';

        CoInitialize(nil);
        vIManDMS := CoManDMS.Create;

        cMensagem := 'obter a sessao!';

        If  ((pServerName = null) Or (Trim(pServerName) = '')) then
            pServerName := fDoc('session');

        IManDMS(vIManDMS).Get_Sessions(vIManSessions);
        vIManSessions.Add(pServerName{Servidor},vIManSession);

        vAllDataBaseNames := CoManStrings.Create;
        vAllDataBaseNames.Add(fDoc('database'));

        cMensagem := 'tentar logar no worksite!';

        vIManSession.Login(cUsuario, cSenha);

        vIManSession.Get_Connected(vConnected);

        If  vConnected then begin

            cMensagem := 'obter o documento no worksite!';

            vIManSession.Set_AllVersions(False);

            //*** Prepara vSearchParameters para receber os valores de filtragem ***
            vIManDMS.CreateProfileSearchParameters(vSearchParameters);

            vSearchParameters.Add(imProfileDatabase, fDoc('database'), vSearchParameter);
            vSearchParameters.Add(imProfileDocNum  , fDoc('document'), vSearchParameter);
            vSearchParameters.Add(imProfileVersion , fDoc('versao')  , vSearchParameter);

            vPesq := True;
            vIManSession.Set_MaxRowsForSearch(1000);  //Qtde de linhas da pesquisa
            vIManSession.Set_Timeout(1000000);     //Tempo limite da pesquisa

            //*** Filtragem dos documentos em vContents ***
            vIManSession.SearchDocuments(vAllDataBaseNames, vSearchParameters, vPesq, vContents);

            vContents.ItemByIndex(1, IManContent(vDocument));

            //Obtem o nome que esta gravado nos campos Alltrim(NUM_DESC) +'.'+ Alltrim(NUM_EXTEN)
            cNome := Trim(fnLimpaNome(pNomeArq));
            cLocal := pPasta + '\' + cNome;

            //*** Copia o arquivo para a pasta local. ***
            vDocument.GetCopy(cLocal, imNativeFormat);

            If  FileExists(cLocal) then begin
                Result := 1;
                fnCreateFile('SIGAGEDW.LOG', 'Arquivo exportado: ' + cLocal);
            End{If} Else begin
                fnCreateFile('SIGAGEDW.LOG', 'Arquivo nao exportado: ' + cLocal);
            End{Else};

        End{If} Else begin

            fnCreateFile('SIGAGEDW.LOG', 'Erro na conexão com a base de documentos.');

        End{Else};

     except
        On e : Exception do begin
            fnCreateFile('SIGAGEDW.LOG', 'Erro ao ' + cMensagem);
            fnCreateFile('SIGAGEDW.LOG', e.Message);
        End;
     end;

end;

{
Autor: Antonio C Ferreira - acferreira - 23/04/2015

Utilizado para importar um documento para o GED
Parametros
pServerName - Servidor do WorkSite = WORKSITE
pUserID     - Usuario para conexao
pPassword   - Senha para conexao
plcArquivo  - URL do documento que deve ser importado (nome do arquivo com o path)
Retorno
Valor String (PCHAR) com a URL do documento importado

}
function ImportWDoc(pServerName, pDataBase, pUserID, pPassword, plcCliente, plcCaso, plcArqRet, plcArquivo, plcFichaWorkSite : WideString) : String; stdcall;
var
    aDataBases         : IManDataBases;
    aDatabase          : IManDataBase;
    cDataBase          : WideString;
    vAllDataBaseNames  : IManStrings;
    vIManSessions      : IManSessions;
    vIManFolders       : IManFolders;
    vIManFolder        : IManFolder;
    vIManSubFolders    : IManFolders;
    vIManSubFolder     : IManFolder;
    vPropriedades      : IManAdditionalProperties;
    vPropriedade       : IManAdditionalProperty;
    vSearchParameters  : IManWorkSpaceSearchParameters;
    vProfileParameters : IManProfileSearchParameters;
    vProfileParameter  : IManProfileSearchParameter;
    oTipo              : IManDocumentType;
    cTipo              : WideString;
    pImportCmd         : TImportCmd;
    pContextItems      : TContextItems;
    lConnected         : WordBool;
    cObjectID          : String;
    cDescription       : String;
    cExtension         : String;
    nPastas            : Integer;
    nDocs              : Integer;
    nProps             : Integer;
    vNRTDocument       : OleVariant;
    cUsuario           : WideString;
    cSenha             : WideString;
    cPasta             : WideString;
    cPropValor         : WideString;
    cClasse            : WideString;
    cMensagem          : String;
    nA                 : Integer;
    oObjeto            : TEventTarget;
    ArqRet             : TextFile;
    cPropNome          : WideString;
    nProp, nPropIndex  : Integer;
begin
  try
    Result := 'Erro';

    cUsuario := Decode64(pUserID);   //Descriptografa da Base64.
    cSenha   := Decode64(pPassword);


    fnCreateFile('SIGAGEDW.LOG', 'Iniciando importação - ' + DateToStr(Date) + ' - ' + TimeToStr(Time));
    fnCreateFile('SIGAGEDW.LOG', 'Arquivo: ' + plcArquivo);

    try

        cMensagem := 'obtendo os atributos do parametro!';

        If  (Not FichaWorkSite(plcFichaWorkSite, cClasse, aParametros)) then begin
            //raise exception.Create('Problema para obter os atributos do parametro! Cliente: ' + Trim(plcCliente) + ' Caso: ' + plcCaso);
            fnCreateFile('SIGAGEDW.LOG', 'Problema para obter os atributos do parametro! Cliente: ' + Trim(plcCliente) + ' Caso: ' + plcCaso);
            Exit;
        End{If};

        cMensagem := 'criar o objeto!';

        CoInitialize(nil);
        vIManDMS := CoManDMS.Create;

        cMensagem := 'obter a sessao!';

        IManDMS(vIManDMS).Get_Sessions(vIManSessions);
        vIManSessions.Add(pServerName{Servidor},vIManSession);

        vAllDataBaseNames := CoManStrings.Create;
        vAllDataBaseNames.Add(pDataBase);

        cMensagem := 'tentar logar no worksite!';

        vIManSession.Login(cUsuario, cSenha);

        vIManSession.Get_Connected(lConnected);

        If  lConnected then begin

            cMensagem := 'pesquisar a pasta no worksite!';

            vIManSession.Get_Databases(aDataBases);
            aDataBases.ItemByName(pDataBase,aDatabase);

            aDatabase.Get_Name(cDataBase);
            fnCreateFile('SIGAGEDW.LOG', 'cDataBase: ' + cDataBase);

            //*** Prepara vSearchParameters para receber os valores de filtragem ***
            IManDMS(vIManDMS).CreateProfileSearchParameters(vProfileParameters);

            vProfileParameters.Add(imProfileCustom1, plcCliente, vProfileParameter);
            vProfileParameters.Add(imProfileCustom2, plcCaso   , vProfileParameter);

            //*** Prepara vSearchParameters para receber os valores de filtragem da WorkArea ***
            IManDMS(vIManDMS).CreateWorkSpaceSearchParameters(vSearchParameters);

             vIManSession.SearchWorkspaces(vAllDataBaseNames, vProfileParameters, vSearchParameters, vIManFolders);

            vIManFolders.Get_Count(nPastas);

            If  (nPastas <= 0) then begin
                //raise exception.Create('Nenhuma pasta encontrada com este cliente e caso! Cliente: ' + Trim(plcCliente) + ' Caso: ' + plcCaso);
                fnCreateFile('SIGAGEDW.LOG', 'Erro ao ' + cMensagem);
                fnCreateFile('SIGAGEDW.LOG', 'Erro: Nenhuma pasta encontrada com este cliente e caso! Cliente: ' + Trim(plcCliente) + ' Caso: ' + plcCaso);
            End{If};

            vIManFolders.ItemByIndex(1,vIManFolder);
            vIManFolder.Get_Name(cPasta);
            vIManFolder.Get_SubFolders(vIManSubFolders);
            vIManSubFolders.Get_Count(nPastas);

            //Procura a pasta dentro da area de trabalho através da classe
            For nA := 1 to nPastas do begin
                vIManSubFolders.ItemByIndex(nA, vIManSubFolder);
                vIManSubFolder.Get_Name(cPasta);
                vIManSubFolder.Get_AdditionalProperties(vPropriedades);
                vPropriedades.Get_Count(nProps);

                For nProp := 1 to nProps do
                begin
                  vPropriedades.ItemByIndex(nProp, vPropriedade);
                  vPropriedade.Get_Name(cPropNome);
                  vPropriedade.Get_Value(cPropValor);

                  if cPropNome = 'iMan___8' then
                    nPropIndex := nProp;
                end;
                nProp := 0;

                vPropriedades.ItemByIndex(nPropIndex, vPropriedade);
                vPropriedade.Get_Value(cPropValor);

                {  PROPRIEDADES DA PASTA
                   Pasta..: Ata de Reunião
                   nB.: 1
                   Nome..: iMan___8
                   Valor.: 12        => Classe
                   nB.: 2
                   Nome..: iMan___25
                   Valor.: 618       => Cliente
                   nB.: 3
                   Nome..: iMan___26
                   Valor.: 520       => Caso
                }

                If  (cPropValor = cClasse) then
				  Break; //Pasta selecionada

            End{For};

            cMensagem := 'verificando o arquivo a ser importado!';



            cMensagem := 'importar o arquivo para o worksite!';

            //Configura a importação
            pContextItems := TContextItems.Create(nil);
            pContextItems.Add('IManDestinationObject'         , vIManSubFolder );
            pContextItems.Add('IManExt.Import.FileName'       , plcArquivo     );
            pContextItems.Add('IManExt.Import.DocAuthor'      , cUsuario       );
            pContextItems.Add('IManExt.NewProfile.ProfileNoUI', True {Sem Tela} );

            //Prepara o evento de inicialização para atualizar os atributos/campos de importação
            oObjeto := TEventTarget.Create();

            //Comando de Importação do documento
            pImportCmd := TImportCmd.Create(nil);
            pImportCmd.OnInitDialog := oObjeto.pOnInitDialog; //Evento de inicialização
            pImportCmd.Initialize(pContextItems.DefaultInterface);
            pImportCmd.Update;
            pImportCmd.Execute;

            //Obtem o link do documento no Worksite
            If  pContextItems.Item('IManExt.Refresh') then begin

                vNRTDocument := pContextItems.Item('ImportedDocument');
                cObjectID    := vNRTDocument.ID;
                cDescription := ReplaceSTR(vNRTDocument.Description);
                cExtension   := vNRTDocument.Extension;
                nDocs        := vNRTDocument.Number;

                Result       := cObjectID+' '+IntToStr(nDocs)+' '+cExtension+' '+cDescription;

                fnCreateFile('SIGAGEDW.LOG', 'Result: ' + Result);

                //Grava o link worksite do documento importado no Arquivo de Retorno para o Protheus
                fnCreateFile(plcArqRet, Result, False);

            End{If};
        End{If};

    except
        On e : Exception do begin
            fnCreateFile('SIGAGEDW.LOG', 'Erro ao ' + cMensagem);
            fnCreateFile('SIGAGEDW.LOG', e.Message);
            Exit;
        End{On};
    end{except};
  Finally
  End;

end;


function IndexOfArray(Items: array of String; const Value: String): Integer;
var
   i: Integer;
begin

   Result := -1;

   For i := Low(Items) to High(Items) do begin
       If  AnsiSameText(Value, Items[i]) then begin
           Result := i;
           Break;
       End{if};
   End{for};

end;


procedure TEventTarget.pOnInitDialog(Sender: TObject; var pMyInterface: OleVariant);
const
    Atributos : array[1..100] of string =
        ('nrDatabase' , 'nrDocNum'    , 'nrVersion'        , 'nrDescription', 'nrName'     ,
         'nrAuthor'   , 'nrOperator'  , 'nrType'           , 'nrClass'      , 'nrSubClass' ,
         'nrEditDate' , 'nrCreateDate', 'nrRetainDays'     , 'nrSize'       , 'nrIndexable',
         'nrIsRelated', 'nrLocation'  , 'nrDefaultSecurity', 'nrLastUser'   , 'nrInUseBy'  ,
         'nrNetNode'  , 'nrInUse'     , 'nrCheckedOut'     , 'nrArchived'   , 'nrComment'  ,
         'nrCustom1'  , 'nrCustom2'   , 'nrCustom3'        , 'nrCustom4'    , 'nrCustom5'  ,
         'nrCustom6'  , 'nrCustom7'   , 'nrCustom8'        , 'nrCustom9'    , 'nrCustom10' ,
         'nrCustom11' , 'nrCustom12'  , 'nrCustom13'       , 'nrCustom14'   , 'nrCustom15' ,
         'nrCustom16' , 'nrCustom17'  , 'nrCustom18'       , 'nrCustom19'   , 'nrCustom20' ,
         'nrCustom21' , 'nrCustom22'  , 'nrCustom23'       , 'nrCustom24'   , 'nrCustom25' ,
         'nrCustom26' , 'nrCustom27'  , 'nrCustom28'       , 'nrCustom29'   , 'nrCustom30' ,
         'xxNULO-37'  , 'xxNULO-38'   , 'xxNULO-39'        , 'xxNULO-3A'    , 'xxNULO-3B'  ,
         'nrCustom1Description' , 'nrCustom2Description' , 'nrCustom3Description' ,
         'nrCustom4Description' , 'nrCustom5Description' , 'nrCustom6Description' ,
         'nrCustom7Description' , 'nrCustom8Description' , 'nrCustom9Description' ,
         'nrCustom10Description', 'nrCustom11Description', 'nrCustom12Description',
         'nrCustom29Description', 'nrCustom30Description', 'nrAuthorDescription'  ,
         'nrOperatorDescription', 'nrTypeDescription'    , 'nrClassDescription'   ,
         'nrSubClassDescription', 'nrLastUserDescription', 'nrInUseByDescription' ,
         'nrEditTime'           , 'nrExtension'          , 'nrFullText'           ,
         'nrSubType'            , 'nrEditProfileTime'    , 'xxNULO-56'            ,
         'xxNULO-57'            , 'xxNULO-58'            , 'nrContainerID'        ,
         'xxNULO-5A'            , 'xxNULO-5B'            , 'xxNULO-5C'            ,
         'xxNULO-5D'            , 'xxNULO-5F'            , 'nrCustom31'           ,
         'nrMarkedForArchive'   , 'nrEchoEnabled'        , 'nrAccessTime'         ,
         'nrMessageUniqueID');
var
    nA    : Integer;
    nPos  : Integer;
begin

    For nA := Low(aParametros) to High(aParametros) do
    begin
        nPos := IndexOfArray(Atributos, aParametros[nA,0]);

        If  (nPos >= 0) then begin
            pMyInterface.SetAttributeValueByID(StrToInt('$'+IntToHex(nPos,8)), aParametros[nA,2], True);
        End{If};

    End{For};

end;


{
Utilizado para fazer interface com o Protheus
Parametros
aFuncID - Código da função que deve ser executada (Obrigatório)
aParams - Lista de parametros para a procedure que será chamada (Não obrigatório)
aBuff - Complemento dos paramêtros (Não obrigatório)
aBuffSize - Tamanho do Buffer de complemento (aBuff) (Não obrigatório)
Retorno
aBuff - pode ser utilizado para retornar valores para o Protheus
}
function ExecInClientDLL(aFuncID: Integer;
                         aParams: PAnsiChar;
                         aBuff: PAnsiChar;
                         aBuffSize: Integer ): integer; stdcall;
var
  vDoc: PAnsichar;
begin
  Result := -1;
  try
    if aFuncID = 1 then  //Login no GED WorkSite (Interwoven) via TrustedLogin
    begin
      if LoginGed(PAnsiChar(aParams),True) then
        Result := 1
      else
        Result := -1;
    end
    else if aFuncID = 2 then  //Login no GED WorkSite (Interwoven) via Tela de Login
    begin
      if LoginGed(PAnsiChar(aParams),False) then
        Result := 1
      else
        Result := -1;
    end
    else if aFuncID = 3 then  //Logout no GED WorkSite (Interwoven)
    begin
      LogoutGed;
      Result := 1;
    end
    else if aFuncID = 4 then  //Logout no GED WorkSite (Interwoven) OpenDocument
    begin
      OpenDoc(aParams);
      Result := 1;
    end
    else if aFuncID = 5 then  //Logout no GED WorkSite (Interwoven) ImportDocument
    begin
      vDoc := aParams; //se mandar aParams = '' (vazio) o tamanho da variavel ira aumentar automaticamente.
                       //se mandar tamanho fixo, ex.: Space(10) ira retornar somente 10 caracteres.
      ImportDoc(vDoc);
      strCopy(aBuff, vDoc);

      if trim(vDoc) <> '' then
        Result := 1
      else
        Result := -1;
    end
    else if aFuncID = 6 then //AttachDoc
    begin
      vDoc := aParams;
      AttachDoc(vDoc);
      strCopy(aBuff, vDoc);
      if trim(vDoc) <> '' then
        Result := 1
      else
        Result := -1;
    end;
  except
    on e: exception do
      Dialogs.MessageDlg('Erro: '+e.Message, mtInformation,[mbOk], 0);
  end;
end;

exports
    ExecInClientDLL, ExportWDoc, ImportWDoc;

begin
end.
