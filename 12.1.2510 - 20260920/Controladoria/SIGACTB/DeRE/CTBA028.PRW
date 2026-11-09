#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'CTBA028.CH'

//--------------------------------------------------
/*/{Protheus.doc} CTBA028
Cadastramento de Códigos de Tributos para a DeRE

@author pierre.nascimento
@since 05/03/2026
@version P12.1.2510
/*/
//--------------------------------------------------
Function CTBA028()

	Local oBrw As Object

    If !FWSX3Util():SeekX3File("QLS_MANUAL")//Proteção para não quebrar enquando a tabela não existir
        Help(" ",1,"NODICQLS",, STR0007, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0008})//"O dicionário da tabela QLS não foi aplicado."###"Utilize o UPDDISTR para criar os componentes necessários."
	    Return
    EndIf
    
    oBrw := FWMBrowse():New()

	oBrw:setDescription(STR0002)//"Códigos de Tributos DERE"
	oBrw:setAlias("QLS")

	oBrw:Activate()

Return

//--------------------------------------------------
/*/{Protheus.doc} MenuDef
Opções do Menu Funcional da rotina CTBA028

@author pierre.nascimento
@since 05/03/2026
@version P12.1.2510

@return array, opcoes de menu da rotina
/*/
//--------------------------------------------------
static function MenuDef() As Object

    Local aRotina As Array 
    aRotina := {}

    ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.CTBA028'	OPERATION 2 ACCESS 0 //"Visualizar"
    ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.CTBA028'	OPERATION 3 ACCESS 0 //"Incluir"
    ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.CTBA028'	OPERATION 4 ACCESS 0 //"Alterar"
    ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.CTBA028'   OPERATION 5 ACCESS 0 //"Excluir" 
    ADD OPTION aRotina TITLE STR0014 ACTION 'CT028Sinc()'       OPERATION 3 ACCESS 0  //"Sincronizar Tributos"

Return (aRotina)

//--------------------------------------------------
/*/{Protheus.doc} ModelDef
Definições do modelo de dados da rotina

@author pierre.nascimento
@since 05/03/2026
@version P12.1.2510

@return objeto, modelo de dados
/*/
//--------------------------------------------------
static function ModelDef() As Object

	Local oModel    As Object
	Local oStr      As Object
    
    oStr := FwFormStruct(1,"QLS")

    oStr:SetProperty( 'QLS_CODTRB' , MODEL_FIELD_WHEN ,{||IIF( !IsBlind(),IIF(INCLUI,.T.,.F.),.T.)}) //Permite editar o código apenas na inclusão.

    oModel := MpFormModel():New("CTBA028",,{|oModel| CT028PosVl(oModel)})//bPosValidacao marca o registro como manual antes da gravação

	oModel:AddFields("QLSMASTER",,oStr)//nomeio o Modelo e coloco a Struct nele
	oModel:SetDescription(STR0002) //"Códigos de Tributos DERE"
	oModel:getModel("QLSMASTER"):SetDescription(STR0002) //"Códigos de Tributos DERE"

return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definição da Interface da Rotina.

@author pierre.nascimento
@since 05/03/2026
@version P12.1.2510
/*/
//-------------------------------------------------------------------
static function ViewDef() As Object

    Local oModel    As Object
	Local oStr      As Object
    Local oView     As Object

    oModel := FwLoadModel("CTBA028")
    oStr := FwFormStruct(2,"QLS")
    oView:= FwFormView():new()

    oStr:RemoveField("QLS_MANUAL")
    oView:setModel(oModel)
    oView:addField("VIEW_QLS",oStr, "QLSMASTER")
    oView:CreateHorizontalBox("TELA",100)
	oView:EnableTitleView("VIEW_QLS", STR0002)//"Códigos de Tributos DERE"

return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} CheckQLS

Sincroniza a tabela QLS com a lista de códigos de tributo DeRE
recebida por parâmetro, incluindo, alterando e excluindo registros
automáticos (QLS_MANUAL != "1") conforme a lista informada.

@author pierre.nascimento
@since 05/08/2026
@version P12.1.2510

@param aCodTrb, array, lista de tributos no formato {Código, Título, DispLegal, DescComp}
/*/
//-------------------------------------------------------------------
Function CheckQLS(aCodTrb As Array)

    Local aCodDel   As Array
    Local nX        As Numeric
    Local cFilQLS   As Character
    Local nTamTrib  As Numeric

    Default aCodTrb := {}

    aCodDel     := {}//Codigos excluidos automaticamente da QLS (verificados depois contra a QLT, em todas as filiais, via query)
    nX          := 0
    cFilQLS     := FwXFilial("QLS")
    nTamTrib    := TAMSX3("QLS_CODTRB")[1]

    /* O Array aCodTrb terá as seguintes informações em ordem 
    1- Codigo do Tributo
    2- Titulo do Tributo
    3- Dispositivo Legal
    4- Descrição Detalhada*/

    dbSelectArea("QLS")
    QLS->(dbSetOrder(1))//QLS_FILIAL+QLS_CODTRB    
    
    For nx := 1 to Len(aCodTrb)
        If !QLS->(DbSeek(cFilQLS+PadR(aCodTrb[nx,1],nTamTrib))) //Inclui apenas se não achar o registro
            RecLock("QLS",.T.)
            QLS->QLS_FILIAL := cFilQLS
            QLS->QLS_CODTRB := aCodTrb[nx,1]
            QLS->QLS_TITULO := aCodTrb[nx,2]
            QLS->QLS_DISLEI := aCodTrb[nx,3]
            QLS->QLS_DSCTRB := aCodTrb[nx,4]
            QLS->QLS_MANUAL := "2" //Registro incluído automaticamente pela rotina

            If Empty(aCodTrb[nx,3]) .AND. Empty(aCodTrb[nx,4]) //Se ambos forem em branco é sintético
                QLS->QLS_CLASSE := "1"
            Else
                QLS->QLS_CLASSE := "2" 
            EndIf

            QLS->(MsUnlock())
        ElseIf QLS->QLS_MANUAL != "1" .AND. (Empty(QLS->QLS_MANUAL) .OR. AllTrim(QLS->QLS_TITULO) != AllTrim(aCodTrb[nx,2]) .OR. AllTrim(QLS->QLS_DISLEI) != AllTrim(aCodTrb[nx,3]) .OR. AllTrim(QLS->QLS_DSCTRB) != AllTrim(aCodTrb[nx,4])) //Só atualiza se o registro for automático e algum dos campos mudou de conteúdo
            RecLock("QLS",.F.)
            QLS->QLS_TITULO := aCodTrb[nx,2]
            QLS->QLS_DISLEI := aCodTrb[nx,3]
            QLS->QLS_DSCTRB := aCodTrb[nx,4]
            QLS->QLS_MANUAL := "2" //Registro alterado automaticamente pela rotina
            QLS->(MsUnlock())
        EndIf
    Next

    //Exclui os registros incluídos automaticamente que não existem mais no array aCodTrb
    dbSelectArea("QLS")
    QLS->(dbSetOrder(1))//QLS_FILIAL+QLS_CODTRB
    QLS->(DbSeek(cFilQLS))
    While !QLS->(Eof()) .AND. QLS->QLS_FILIAL == cFilQLS
        If QLS->QLS_MANUAL != "1" .AND. AScan(aCodTrb,{|aItem| AllTrim(aItem[1]) == AllTrim(QLS->QLS_CODTRB)}) == 0
            aAdd(aCodDel,AllTrim(QLS->QLS_CODTRB))
            RecLock("QLS",.F.)
            QLS->(DbDelete())
            QLS->(MsUnlock())
        EndIf
        QLS->(DbSkip())
    EndDo

    If !IsBlind() .AND. Len(aCodDel) > 0
        CT028AvQLT(CT28GetQLT(aCodDel))
    EndIf
    
Return

//--------------------------------------------------
/*/{Protheus.doc} CT028Sinc
Aciona o fluxo de sincronizacao dos codigos de tributo DeRE a
partir de um arquivo CSV selecionado pelo usuario.

O layout do cabecalho (1a linha) e variavel: as colunas
QLS_CODTRB, QLS_TITULO, QLS_DISLEI e QLS_DSCTRB podem vir em
qualquer ordem no arquivo, identificadas pelo NOME (ver
CT028Pos()), e nao mais por posicao fixa. QLS_CODTRB e
QLS_TITULO precisam estar presentes no cabecalho (mesmo que
alguma linha de dados traga o valor em branco); QLS_DISLEI e
QLS_DSCTRB sao opcionais - se a coluna nao existir no cabecalho,
o respectivo campo simplesmente nao e processado (fica vazio) em
todas as linhas, sem gerar erro. O separador de colunas continua
sendo ";".

@author TOTVS
@since 05/08/2026
@version P12.1.2510
/*/
//--------------------------------------------------
Function CT028Sinc(cArqFile as Character)

    Local cArquivo   As Character
    Local oFile      As Object
    Local cLinha     As Character
    Local aCabec     As Array
    Local aCols      As Array
    Local aCodTrb    As Array
    Local aPosCab    As Array

    Default cArqFile := ""

    aCodTrb     := {}
    cArquivo    := ""
    oFile       := Nil
    cLinha      := ""
    aCabec      := {}
    aCols       := {}
    aPosCab     := {}

    If !Empty(cArqFile)
        cArquivo := cArqFile
    Else
        cArquivo := CT028GetF()
    EndIf    
    
    If Empty(cArquivo)
        Return //Cancelamento silencioso da selecao de arquivo, CheckQLS nao e chamado
    EndIf

    If !File(cArquivo)
        Help(" ",1,"NOFILECSV",, STR0017, 1, 0, NIL, NIL, NIL, NIL, NIL, {})//"Nao foi possivel acessar o arquivo selecionado."
        Return
    EndIf

    oFile := FWFileReader():New(cArquivo) //Leitura via filesystem compartilhado (compativel com SmartERP), ao contrario de FT_FUse/FT_FReadLn

    If !oFile:Open()
        Help(" ",1,"NOFILECSV",, STR0017, 1, 0, NIL, NIL, NIL, NIL, NIL, {})//"Nao foi possivel acessar o arquivo selecionado."
        Return
    EndIf

    If oFile:hasLine()
        cLinha := oFile:GetLine()
        aCabec := StrTokArr2(cLinha, ";", .T.)
    EndIf

    //Localiza, pelo NOME, a posicao de cada coluna do layout dentro do cabecalho (layout variavel)
    aPosCab := CT028Pos(aCabec)

    If !CT028VLay(aCabec, aPosCab)
        oFile:Close() //fecha o arquivo
        Help(" ",1,"LAYOUTCSV",, STR0018, 1, 0, NIL, NIL, NIL, NIL, NIL, {})//"O layout do arquivo selecionado e invalido."
        Return
    EndIf

    While oFile:hasLine()
        cLinha := oFile:GetLine()

        If !Empty(cLinha)
            aCols := StrTokArr2(cLinha, ";", .T.)

            If CT028VLin(aCols, aCabec, aPosCab)
                aAdd(aCodTrb, CT028Mnt(aCols, aPosCab))
            EndIf
        EndIf
    EndDo

    oFile:Close() //fecha o arquivo

    If Len(aCodTrb) == 0
        Help(" ",1,"CSVVAZIO",, STR0019, 1, 0, NIL, NIL, NIL, NIL, NIL, {})//"O arquivo nao gerou nenhum tributo valido. Nenhuma alteracao foi realizada."
        Return
    EndIf

    MsgRun( STR0001 ,, { || CheckQLS(aCodTrb) } )//"Aguarde, estamos preparando a tabela QLS"

    MsgInfo(STR0020, STR0014)//"Tabela QLS atualizada com sucesso."###"Sincronizar Tributos"

Return
//--------------------------------------------------
/*/{Protheus.doc} CT028GetF
Exibe a janela de selecao de arquivo restrita a .csv,
para a sincronizacao de codigos de tributo DeRE.

@author TOTVS
@since 05/08/2026
@version P12.1.2510

@return character, caminho do arquivo selecionado, ou "" se cancelado
/*/
//--------------------------------------------------
Static Function CT028GetF() As Character

    Local cArquivo As Character

    cArquivo := cGetFile(STR0015 + " (*.csv)|*.csv|", STR0016, 0, "", .T., GETF_LOCALHARD + GETF_NETWORKDRIVE)//"Arquivos CSV"##"Selecione o arquivo CSV de Tributos"

Return cArquivo

//--------------------------------------------------
/*/{Protheus.doc} CT028Pos
Localiza, pelo NOME da coluna (comparacao case-insensitive e
sem espacos nas bordas), a posicao de cada campo do layout
(QLS_CODTRB, QLS_TITULO, QLS_DISLEI, QLS_DSCTRB) dentro do
cabecalho do arquivo. Permite que o CSV traga as colunas em
qualquer ordem; quando uma coluna nao existir no cabecalho, sua
posicao retorna 0.

@author TOTVS
@since 05/08/2026
@version P12.1.2510

@param aCabec, array, colunas do cabecalho do arquivo, ja tokenizadas
@return array, {nPosCodTrb, nPosTitulo, nPosDisLei, nPosDscTrb} - 0 quando a coluna nao existe no cabecalho
/*/
//--------------------------------------------------
Static Function CT028Pos(aCabec As Array) As Array

    Local aRet As Array
    Default aCabec := {}

    aRet := {0, 0, 0, 0}

    If ValType(aCabec) == "A" .And. Len(aCabec) > 0
        aRet[1] := Ascan(aCabec, {|cCol| AllTrim(Upper(cCol)) == "QLS_CODTRB"})
        aRet[2] := Ascan(aCabec, {|cCol| AllTrim(Upper(cCol)) == "QLS_TITULO"})
        aRet[3] := Ascan(aCabec, {|cCol| AllTrim(Upper(cCol)) == "QLS_DISLEI"})
        aRet[4] := Ascan(aCabec, {|cCol| AllTrim(Upper(cCol)) == "QLS_DSCTRB"})
    EndIf

Return aRet

//--------------------------------------------------
/*/{Protheus.doc} CT028VLay
Valida se o cabecalho do CSV de tributos contem, no minimo, as
colunas obrigatorias do layout (QLS_CODTRB e QLS_TITULO)

@author TOTVS
@since 05/08/2026
@version P12.1.2510

@param aCabec, array, colunas da 1a linha do arquivo (cabecalho), ja tokenizadas
@param aPosCab, array, posicao de cada campo do layout no cabecalho (ver CT028Pos())
@return logico, .T. se o layout for valido
/*/
//--------------------------------------------------
Static Function CT028VLay(aCabec As Array, aPosCab As Array) As Logical

    Local lRet As Logical

    Default aCabec  := {}
    Default aPosCab := {}

    lRet := .F.

    If ValType(aCabec) == "A" .And. Len(aCabec) > 0
        If aPosCab[1] > 0 .And. aPosCab[2] > 0 //QLS_CODTRB e QLS_TITULO sao obrigatorios no cabecalho
            lRet := .T.
        EndIf
    EndIf

Return lRet

//--------------------------------------------------
/*/{Protheus.doc} CT028VLin
Valida uma linha de dados do CSV de tributos ja tokenizada,
buscando os valores obrigatorios pela posicao mapeada em
aPosCab (layout variavel). A linha e valida quando possui a
mesma quantidade de colunas do cabecalho e os campos QLS_CODTRB
e QLS_TITULO, localizados por posicao, nao estao vazios.

@author TOTVS
@since 05/08/2026
@version P12.1.2510

@param aCols, array, colunas da linha, ja tokenizadas
@param aCabec, array, colunas do cabecalho do arquivo, ja tokenizadas
@param aPosCab, array, posicao de cada campo do layout no cabecalho (ver CT028Pos())
@return logico, .T. se a linha for valida
/*/
//--------------------------------------------------
Static Function CT028VLin(aCols As Array, aCabec As Array, aPosCab As Array) As Logical

    Local lRet As Logical

    Default aCols   := {}
    Default aCabec  := {}
    Default aPosCab := {}

    lRet := .F.

    If (ValType(aCols) == "A" .And. Len(aCols) > 0) .And. Len(aCols) == Len(aCabec)
        If !Empty(AllTrim(aCols[aPosCab[1]])) .And. !Empty(AllTrim(aCols[aPosCab[2]]))
            lRet := .T.
        EndIf
    EndIf

Return lRet

//--------------------------------------------------
/*/{Protheus.doc} CT028Mnt
Monta, a partir de uma linha ja validada do CSV, o item no
formato fixo esperado por CheckQLS() ({Codigo, Titulo,
DispLegal, DescComp}), buscando cada valor pela posicao mapeada
em aPosCab. Quando QLS_DISLEI ou QLS_DSCTRB nao existirem no
cabecalho (posicao 0), o respectivo campo e entregue em branco,
sem tentar processar a informacao.

@author TOTVS
@since 05/08/2026
@version P12.1.2510

@param aCols, array, colunas da linha, ja tokenizadas
@param aPosCab, array, posicao de cada campo do layout no cabecalho (ver CT028Pos())
@return array, {cCodigo, cTitulo, cDispLegal, cDescComp}
/*/
//--------------------------------------------------
Static Function CT028Mnt(aCols As Array, aPosCab As Array) As Array

    Local aRet As Array

    Default aCols   := {}

    aRet := {"", "", "", ""}

    aRet[1] := AllTrim(aCols[aPosCab[1]])
    aRet[2] := AllTrim(aCols[aPosCab[2]])

    If aPosCab[3] > 0
        aRet[3] := AllTrim(aCols[aPosCab[3]])
    EndIf

    If aPosCab[4] > 0
        aRet[4] := AllTrim(aCols[aPosCab[4]])
    EndIf

Return aRet

//--------------------------------------------------
/*/{Protheus.doc} CT28GetQLT
Verifica, via query (FwExecStatement), em todas as filiais
(considerando o compartilhamento proprio da QLT, que segue o
compartilhamento da CT1 e nao o da QLS, que e totalmente
compartilhada), quais dos codigos de tributo excluidos da QLS
ainda possuem amarracao na tabela QLT (Conta x Cod.Trib DeRE).

O array aCodDel e consultado em blocos de ate nBlkSize codigos, pois
o SetIn() expande cada elemento em um placeholder "?" na clausula IN,
e o Oracle limita a 1000 expressoes por lista IN (ORA-01795). Cada
bloco gera sua propria consulta (ja ordenada por filial/codigo) e os
resultados de todos os blocos sao agregados e reordenados ao final,
garantindo a mesma ordenacao global por QLT_FILIAL, QLT_CODTRB
independente da quantidade de blocos necessarios.

@author pierre.nascimento
@since 05/08/2026
@version P12.1.2510

@param aCodDel, array, codigos de tributo excluidos da QLS a verificar
@return array, aRet[n][1]=filial aRet[n][2]=codigo de tributo, ordenado por filial e depois por codigo
/*/
//--------------------------------------------------
Static Function CT28GetQLT(aCodDel As Array) As Array

    Local oStatement    As Object
    Local cAlias        As Character
    Local cQuery        As Character
    Local aRet          As Array
    Local aBlock        As Array
    Local nBlkSize      As Numeric
    Local nTotal        As Numeric
    Local nIni          As Numeric
    Local nFim          As Numeric
    Local nX            As Numeric

    Default aCodDel := {}

    aRet     := {}
    nBlkSize := 900 //Margem de seguranca abaixo do limite de 1000 expressoes do IN do Oracle (ORA-01795)
    nTotal   := Len(aCodDel)
    nIni     := 1
    aBlock   := {}
    nFim     := 0
    nX       := 0

    If nTotal == 0
        Return aRet
    EndIf

    cQuery := " SELECT QLT_FILIAL, QLT_CODTRB "
    cQuery += "   FROM " + RetSqlName("QLT") + " QLT "
    cQuery += "  WHERE QLT.D_E_L_E_T_ = ? "
    cQuery += "    AND QLT.QLT_CODTRB IN ( ? ) "
    cQuery += "  ORDER BY QLT.QLT_FILIAL, QLT.QLT_CODTRB "

    cQuery := ChangeQuery(cQuery)

    While nIni <= nTotal
        nFim   := Min(nIni + nBlkSize - 1, nTotal)
        aBlock := {}

        For nX := nIni to nFim
            aAdd(aBlock,aCodDel[nX])
        Next nX

        oStatement := FWExecStatement():New(cQuery)
        oStatement:SetString(1,Space(1))
        oStatement:SetIn(2,aBlock)

        cAlias := oStatement:OpenAlias()

        While !(cAlias)->(Eof())
            aAdd(aRet,{AllTrim((cAlias)->QLT_FILIAL),AllTrim((cAlias)->QLT_CODTRB)})
            (cAlias)->(DbSkip())
        EndDo

        (cAlias)->(DbCloseArea())
        oStatement:Destroy()

        nIni := nFim + 1
    EndDo

    //A uniao dos blocos preserva a ordenacao de cada consulta individual, mas nao garante
    //a ordenacao global quando ha mais de um bloco. Reordena o resultado consolidado por
    //filial e, dentro da filial, por codigo de tributo, reproduzindo o ORDER BY original.
    If Len(aRet) > 1
        aSort(aRet,,,{|x,y| x[1] < y[1] .OR. (x[1] == y[1] .AND. x[2] < y[2])})
    EndIf

Return aRet

//--------------------------------------------------
/*/{Protheus.doc} CT028AvQLT
Exibe ao usuario, em uma unica mensagem, todos os codigos de
tributo que foram excluidos da QLS (por nao existirem mais na
carga oficial) mas que possuem amarracao na tabela QLT
(Conta x Cod.Trib DeRE) em alguma filial, agrupados por filial,
para que o usuario revise essas contas.

Utiliza TMultiGet dentro de uma dialog propria (em vez de MsgAlert/
MsgInfo) para garantir que a mensagem nao seja cortada, independente
da quantidade de codigos e filiais.

@author pierre.nascimento
@since 05/08/2026
@version P12.1.2510

@param aFilCod, array, aFilCod[n][1]=filial aFilCod[n][2]=codigo de tributo (ordenado por filial)
/*/
//--------------------------------------------------
Static Function CT028AvQLT(aFilCod As Array)

    Local oDlg          As Object
    Local oMemo         As Object
    Local oBtn          As Object
    Local cMsg          As Character
    Local cFilAtu       As Character
    Local nI            As Numeric

    If Len(aFilCod) == 0
        Return
    EndIf

    cFilAtu := ""
    cMsg := STR0009+CRLF//"Os códigos de tributo abaixo foram excluídos da tabela QLS, porem"
    cMsg += STR0010+CRLF//"possuem amarração na tabela QLT (Conta x Cod.Trib DeRE)."
    cMsg += STR0011+CRLF+CRLF//"Revise a amarração desses tributos:"

    For nI := 1 to Len(aFilCod)
        If aFilCod[nI,1] != cFilAtu
            cFilAtu := aFilCod[nI,1]
            cMsg += CRLF + "Filial " + cFilAtu + ":" + CRLF
        EndIf
        cMsg += aFilCod[nI,2] + CRLF
    Next nI

    DEFINE MSDIALOG oDlg FROM 0,0 TO 350,415 PIXEL TITLE STR0012//"Amarracao QLT pendente de revisao"
    oMemo := TMultiGet():New(5,5,{|u| If(Pcount()>0,cMsg:=u,cMsg)},oDlg,200,150,,.T.,,,,.T.)
    @ 160,175 BUTTON oBtn PROMPT STR0013 OF oDlg PIXEL ACTION oDlg:End()//"Ok"
    ACTIVATE MSDIALOG oDlg CENTERED

Return

//--------------------------------------------------
/*/{Protheus.doc} CT028PosVl
Pós validação do modelo de dados. Marca o registro como
incluído/alterado manualmente (QLS_MANUAL = "1"), garantindo que
qualquer gravação feita via tela, ExecAuto ou MVC (fluxos que
passam pelo Model) não seja tratada como carga automática pela
rotina CheckQLS().

@author pierre.nascimento
@since 05/08/2026
@version P12.1.2510

@param oModel, objeto, modelo de dados da rotina
@return logico, indica se a validação foi bem sucedida
/*/
//--------------------------------------------------
static function CT028PosVl(oModel as Object) As Logical

    Local oModelQLS  As Object
    Local nOper      As Numeric
    oModelQLS := oModel:GetModel("QLSMASTER")
    nOper:= oModelQLS:GetOperation() 

    If nOper <> MODEL_OPERATION_DELETE
        oModelQLS:SetValue("QLS_MANUAL","1")//"1"=Sim (Manual). Campo de controle interno, não exposto na tela.
    EndIf    

Return .T.
