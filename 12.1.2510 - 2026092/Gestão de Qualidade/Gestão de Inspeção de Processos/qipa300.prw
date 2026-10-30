#INCLUDE "TOTVS.CH"
#INCLUDE "QIPA300.CH"

/*/{Protheus.doc} QIPA300AuxClass
Processa encerramento urgente em lote para inspeções em aberto
@author brunno.costa
@since 29/04/2024
@version 1.0
/*/
Function QIPA300()

    Local cFrom            := ""
    Local oQIPA300AuxClass := QIPA300AuxClass():New()

    If !FWIsAdmin(RetCodUsr())
        //STR0001 - "Acesso permitido somente para usuários do grupo Administradores do Configurador."
        //STR0002 - "Falha no acesso."
        ApMsgStop(STR0001,STR0002)
        Return
    EndIf

    If oQIPA300AuxClass:criaTelaParametros(@oQIPA300AuxClass:aRespostas)
        
        oQIPA300AuxClass:cFilQPL      := xFilial("QPL")
        oQIPA300AuxClass:cFilQQL      := xFilial("QQL")

        cFrom := oQIPA300AuxClass:montaFromQuery()
        //STR0003 - "Contando Registros..."
        MsgRun(OemToAnsi(STR0003),STR0003,{|| oQIPA300AuxClass:nRegistros := oQIPA300AuxClass:contaRegistrosValidos(cFrom) })

        If oQIPA300AuxClass:nRegistros == 0
        
            //STR0005 - "Não existem registros válidos para encerramento."
            //STR0004 - "Sem Registros"
            ApMsgInfo(STR0005, STR0004)

            //STR0006 - "Esta ação é irreversível!!! Foram encontrados "
            //STR0007 - " inspeções para encerramento. Recomendamos que seja realizado teste de processamento em um ambiente de testes antes de processar no ambiente de produção. Você deseja prosseguir?"
            //STR0008 - "Você deseja prosseguir?"
        ElseIf ApMsgYesNo(STR0006 + cValToChar(oQIPA300AuxClass:nRegistros) + STR0007, STR0008)

            Processa({|| oQIPA300AuxClass:processaEncerramento(cFrom) })

            //STR0009 - "Processamento finalizado para "
            //STR0010 - " registros."
            //STR0011 - "Processamento Finalizado."
            ApMsgInfo(STR0009 + cValtoChar(oQIPA300AuxClass:nRegistros) + STR0010, STR0011)

        EndIf

    EndIf

Return

/*/{Protheus.doc} QIPA300AuxClass
Classe agrupadora de métodos auxiliares do QIPA300
@author brunno.costa
@since 29/04/2024
@version 1.0
/*/
CLASS QIPA300AuxClass FROM LongNameClass

    DATA aRespostas   as ARRAY
    DATA cAlias       as STRING
    DATA cFilQPL      as STRING
    DATA cFilQQL      as STRING
    DATA cLaboratorio as STRING
    DATA cOperacao    as STRING
    DATA nRegistros   as INTEGER
    DATA oManager     as OBJECT

    METHOD new() Constructor
    METHOD contaRegistrosValidos(cFrom)
    METHOD criaAliasInspecoesAEncerrar(cFrom)
    METHOD criaTelaParametros(aRespostas)
    METHOD incluiAssinatura()
    METHOD incluiLaudo()
    METHOD montaFromQuery(aRespostas)
    METHOD processaEncerramento(cFrom)
    
ENDCLASS

/*/{Protheus.doc} New
Construtor da Classe
@author brunno.costa
@since 29/04/2024
@version 1.0
/*/
Method New() CLASS QIPA300AuxClass
    self:aRespostas := {}
    self:oManager   := QLTQueryManager():New()
Return

/*/{Protheus.doc} criaTelaParametros
Monta tela de parametos
@author brunno.costa
@since 29/04/2024
@version 1.0
@return lReturn, lógico, indica a seleção dos parâmetros de processamento
/*/
Method criaTelaParametros() CLASS QIPA300AuxClass
    Local aPergs     := {}
    Local lReturn    := .F.
    Local nTamaProdu := GetSx3Cache("QP6_PRODUT", "X3_TAMANHO")
    Local nTamJustif := GetSx3Cache("QPL_JUSTLA", "X3_TAMANHO") - 6

    /* 	[1]: Tipo do parâmetro  (numérico) -> 1 - MsGet
        [2]: Descrição
        [3]: String contendo o inicializador do campo
        [4]: String contendo a Picture do campo
        [5]: String contendo a validação
        [6]: Consulta F3
        [7]: String contendo a validação When
        [8]: Tamanho do MsGet
        [9]: Flag .T./.F. Parâmetro Obrigatório ? */

    aAdd(aPergs, {1, STR0012, Ctod(Space(8))   , , 'NaoVazio()',    "", "", 50 , .T.}) //"Da Dt. Emissão" 
    aAdd(aPergs, {1, STR0013, Ctod(Space(8))   , , 'NaoVazio()',    "", "", 50 , .T.}) //"A Dt. Emissão" 
    aAdd(aPergs, {1, STR0014, SPACE(nTamaProdu), , '.T.'       , "SB1", "", 70 , .F.}) //"Do Produto"
    aAdd(aPergs, {1, STR0015, SPACE(nTamaProdu), , '.T.'       , "SB1", "", 70 , .F.}) //"Ao Produto"
    aAdd(aPergs, {1, STR0016, SPACE(nTamJustif), , 'NaoVazio()',    "", "", 120, .T.}) //"Roteiro Primário"

    If ParamBox(aPergs, STR0017, @self:aRespostas,,, .T.,,, NIL, "QIPA300", .F., .F.) //"Parâmetros"
        lReturn  := .T.
    EndIf
    
Return lReturn

/*/{Protheus.doc} montaFromQuery
Monta trecho de FROM da Query e seleção dos registros à encerrar
@author brunno.costa
@since 29/04/2024
@version 1.0
@return cFrom, caracter, trecho de FROM da query
/*/
Method montaFromQuery() CLASS QIPA300AuxClass
    
    Local cFrom := ""

    cFrom += " FROM " + RetSqlName("QPK") + " QPK "

    cFrom +=     " INNER JOIN "
    cFrom +=         " (SELECT QQK_CODIGO, "
    cFrom +=                 " QQK_OPERAC, "
    cFrom +=                 " QQK_PRODUT, "
    cFrom +=                 " QQK_REVIPR, "
    cFrom +=                 " QQK_DESCRI, "
    cFrom +=                 " QQK_RECURS  "
    cFrom +=         " FROM " + RetSqlName("QQK")
    cFrom +=         " WHERE (D_E_L_E_T_ = ' ')  "
    cFrom +=         " AND (QQK_FILIAL = '" + xFilial("QQK") + "')) QQK  "
    cFrom +=     " ON  QPK.QPK_REVI   = QQK.QQK_REVIPR  "
    cFrom +=     " AND QPK.QPK_PRODUT = QQK.QQK_PRODUT "

    cFrom +=     " LEFT JOIN  "
    cFrom +=         " (SELECT QPL_OP, "
    cFrom +=                 " QPL_LOTE, "
    cFrom +=                 " QPL_NUMSER, "
    cFrom +=                 " QPL_ROTEIR, "
    cFrom +=                 " QPL_OPERAC, "
    cFrom +=                 " QPL_LAUDO "
    cFrom +=         " FROM " + RetSqlName("QPL")
    cFrom +=         " WHERE (D_E_L_E_T_ = ' ')  "
    cFrom +=         " AND (QPL_FILIAL = '" + self:cFilQPL + "') "
    cFrom +=         " AND (QPL_LABOR = ' ') "
    cFrom +=         " AND (QPL_LAUDO <> ' ') ) QPL  "
    cFrom +=     " ON  QPL_OP	   = QPK_OP "
    cFrom +=     " AND QPL_LOTE   = QPK_LOTE "
    cFrom +=     " AND QPL_NUMSER = QPK_NUMSER "
    cFrom +=     " AND QPL_ROTEIR = QQK_CODIGO "

    cFrom += " WHERE (QPK.D_E_L_E_T_ = ' ') "
    cFrom +=   " AND (QPK.QPK_FILIAL = '" + xFilial("QPK") + "') "

    If !Empty(self:aRespostas[1]) .AND. !Empty(self:aRespostas[2])
        cFrom +=   " AND (QPK.QPK_EMISSA BETWEEN '" + DtoS(self:aRespostas[1]) + "' AND '" + DtoS(self:aRespostas[2]) + "') "
    EndIf

    If !Empty(self:aRespostas[4])
        cFrom +=   " AND (QPK.QPK_PRODUT BETWEEN '" + self:aRespostas[3] + "' AND '" + self:aRespostas[4] + "') "
    EndIf

    cFrom +=   " AND (QPL.QPL_OP IS NULL) "
    
Return cFrom

/*/{Protheus.doc} criaAliasInspecoesAEncerrar
Cria alias de inspeções a encerrar
@author brunno.costa
@since 29/04/2024
@version 1.0
@param 01 - cFrom, caracter, trecho de FROM da query
@return cAlias, caracter, alias criado
/*/
Method criaAliasInspecoesAEncerrar(cFrom) CLASS QIPA300AuxClass
    
    Local cQuery := ""

    cQuery += " SELECT QPK_OP, QPK_LOTE, QPK_NUMSER, QQK_CODIGO, QQK_OPERAC, QPL_LAUDO, QPK.R_E_C_N_O_ RECNOQPK, QPK_PRODUT, QPK_EMISSA "
    cQuery += cFrom
    cQuery := self:oManager:changeQuery(cQuery)
    
Return self:oManager:executeQuery(cQuery)

/*/{Protheus.doc} contaRegistrosValidos
Conta registros válidos para encerramento
@author brunno.costa
@since 29/04/2024
@version 1.0
@param 01 - cFrom, caracter, trecho de FROM da query
@return nRegistros, número, quantidade de registros aptos para encerramento
/*/
Method contaRegistrosValidos(cFrom) CLASS QIPA300AuxClass
    
    Local cAlias     := ""
    Local cQuery     := ""
    Local nRegistros := 0

    cQuery += " SELECT COUNT(QPK.R_E_C_N_O_) QTDE "
    cQuery += cFrom
    cQuery := self:oManager:changeQuery(cQuery)
    cAlias := self:oManager:executeQuery(cQuery)

    If !Empty((cAlias)->QTDE)
        nRegistros := (cAlias)->QTDE
    EndIf
    
Return nRegistros

/*/{Protheus.doc} montaFromQuery
Monta trecho de FROM da Query e seleção dos registros à encerrar
@author brunno.costa
@since 29/04/2024
@version 1.0
/*/
Method incluiLaudo() CLASS QIPA300AuxClass

    If QPL->(dbSeek(self:cFilQPL+(Self:cAlias)->QPK_OP+(Self:cAlias)->QPK_LOTE+(Self:cAlias)->QPK_NUMSER+(Self:cAlias)->QQK_CODIGO+self:cOperacao+self:cLaboratorio))
        RecLock("QPL",.F.)
    Else
        RecLock("QPL",.T.)
    Endif

    QPL->QPL_FILIAL	:= self:cFilQPL
    QPL->QPL_PRODUT	:= (Self:cAlias)->QPK_PRODUT
    QPL->QPL_DTENTR	:= StoD((Self:cAlias)->QPK_EMISSA)
    QPL->QPL_LOTE	:= (Self:cAlias)->QPK_LOTE
    QPL->QPL_OP 	:= (Self:cAlias)->QPK_OP
    QPL->QPL_OPERAC	:= self:cOperacao
    QPL->QPL_ROTEIR := (Self:cAlias)->QQK_CODIGO
    QPL->QPL_NUMSER := (Self:cAlias)->QPK_NUMSER
    QPL->QPL_LAUDO  := "U"
    QPL->QPL_JUSTLA := STR0018 + self:aRespostas[5] //"[AUTO]"
    MsUnLock()

Return 

/*/{Protheus.doc} incluiAssinatura
Inclui assinatura do laudo
@author brunno.costa
@since 29/04/2024
@version 1.0
/*/
Method incluiAssinatura() CLASS QIPA300AuxClass

    Local cLaudo := "U"

    If QQL->(!DbSeek(self:cFilQQL+(Self:cAlias)->QPK_OP+"  "+"      "))
    
        RecLock("QQL",.T.)
            QQL->QQL_FILIAL  := self:cFilQQL
            QQL->QQL_OP      := (Self:cAlias)->QPK_OP
            QQL->QQL_OPERAC  := "  "
            QQL->QQL_LAB     := "      "
            QQL->QQL_RESP    := cUserName
            QQL->QQL_DATA    := dDataBase
            QQL->QQL_HORA    := Left(Time(),5)
            QQL->QQL_LAUDO   := cLaudo
        QQL->(MsUnLock())

    ElseIf QQL->(DbSeek(self:cFilQQL+(Self:cAlias)->QPK_OP+"  "+"      ")) .AND. QQL->QQL_LAUDO <> cLaudo

        RecLock("QQL",.F.)
            QQL->QQL_RESP    := cUserName
            QQL->QQL_DATA    := dDataBase
            QQL->QQL_HORA    := Left(Time(),5)
            QQL->QQL_LAUDO   := cLaudo
        QQL->(MsUnLock())

    EndIf
Return 

/*/{Protheus.doc} processaEncerramento
Processa encerramento dos registros
@author brunno.costa
@since 29/04/2024
@version 1.0
@param 01 - cFrom, caracter, trecho de FROM da query
/*/
Method processaEncerramento(cFrom) CLASS QIPA300AuxClass
    
    Local cAlias      := ""
    Local cPercentual := ""
    Local nAtual      := 0

    dbSelectArea("QPL")
    QPL->(dbSetOrder(3))

    DbSelectArea("QQL")
    QQL->(DbSetOrder(2))

    cAlias := self:criaAliasInspecoesAEncerrar(cFrom)

    self:cOperacao    := Space(TamSx3("QPL_OPERAC")[1])
    self:cLaboratorio := Space(TamSx3("QPL_LABOR")[1])
    self:cAlias       := cAlias

    ProcRegua( self:nRegistros )

    (cAlias)->(DbGoTop())
    While (cAlias)->(!Eof())

        Begin Transaction

            nAtual++
            cPercentual := cValToChar(Round(nAtual / self:nRegistros * 100, 2))
            
            //STR0019 - "Processando OP "
            //STR0020 - ". Registro "
            //STR0021 + " de "
            IncProc(STR0019 + AllTrim((cAlias)->QPK_OP) + STR0020 + cValtoChar(nAtual) + STR0021 + cValToChar(self:nRegistros) + " (" + cPercentual + "%).")
            ProcessMessages() // FORÇA O DESCONGELAMENTO DO SMARTCLIENT

            self:incluiLaudo(cAlias)
            self:incluiAssinatura(cAlias)

            QPK->(DbGoTo((cAlias)->RECNOQPK))
            RecLock("QPK",.F.)
            QPK->QPK_LAUDO  := "U"
            QPK->QPK_SITOP  := "4"
            QPK->QPK_CHAVE  := QA_NewChave()
            QPK->QPK_CERQUA := QA_SEQUSX6("QIP_CEQU",TamSX3("C2_CERQUA")[1],"S",STR0022)  //"Certificado Qualidade"
            QPK->(MsUnLock())
            
            QA_GrvTxt(QPK->QPK_CHAVE,"QIPA210U",1,{{1,"[AUTO]" + self:aRespostas[5]}})

        End Transaction

        (cAlias)->(DbSkip())
    EndDo
    
Return 
