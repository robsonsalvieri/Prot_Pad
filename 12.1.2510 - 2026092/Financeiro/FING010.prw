#Include "protheus.ch"
#Include "topconn.ch"
#include "fwmvcdef.ch"
#Include "fileio.ch"
#Include "FING010.ch"

Static __cOrigem := ""
Static __cTbl    := ""

/*/{Protheus.doc} FING010

    Rotina de cadastro de Flex Fields.

    @type  Function
    @author Alecsandre Aparecido Fabiano Santana Ferreira
    @since 03/03/2025
    @version 1.0

    @return Nil
/*/
Function FING010()

    Local oBrowse as Object

    If FWIsAdmin()
        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias("F7O")
        oBrowse:SetDescription(STR0011)
        oBrowse:Activate()
    Else
        FWAlertError(STR0012, STR0013)
    EndIf

    FwFreeObj(oBrowse)
Return

/*/{Protheus.doc} ModelDef

    Define o modelo de dados da rotina FING010.

    @type  Function
    @author Alecsandre Aparecido Fabiano Santana Ferreira
    @since 03/03/2025
    @version 1.0

    @return Object, Modelo FWFormModel da rotina
/*/
Static Function ModelDef()
    Local oModel as Object
    Local oStruF7O as Object
    Local oEvent as Object

    oStruF7O := FwFormStruct(1, 'F7O')
    oModel := MPFormModel():New('FING010',, {|oModel|PosVldFlex(oModel)})
    oEvent := F7OCommit():New()

    oModel:AddFields('F7O_MASTER',, oStruF7O)
    oModel:SetDescription(STR0014)
    oModel:GetModel('F7O_MASTER'):SetDescription('FlexFields')
    oModel:SetPrimaryKey({"F7O_FILIAL", "F7O_ORIGEM", "F7O_TABELA", "F7O_COLUNA", "F7O_FLEX"})

    oModel:InstallEvent("F7OCommit", /*cOwner*/, oEvent)
Return oModel

/*/{Protheus.doc} MenuDef

    Monta o menu de operacoes da rotina FING010.

    @type  Function
    @author Alecsandre Aparecido Fabiano Santana Ferreira
    @since 03/03/2025
    @version 1.0

    @return Array, Opcoes de menu para a view
/*/
Static Function MenuDef()
    Local aRotina := {}
    
    aAdd(aRotina, {'Visualizar', 'VIEWDEF.FING010', 0, 2, 0, NIL})
    aAdd(aRotina, {'Incluir', 'VIEWDEF.FING010', 0, 3, 0, NIL})
    aAdd(aRotina, {'Alterar', 'VIEWDEF.FING010', 0, 4, 0, NIL})
    aAdd(aRotina, {'Excluir', 'VIEWDEF.FING010', 0, 5, 0, NIL})
Return aRotina

/*/{Protheus.doc} ViewDef

    Define a view da rotina FING010.

    @type  Function
    @author Alecsandre Aparecido Fabiano Santana Ferreira
    @since 03/03/2025
    @version 1.0

    @return Object, View FWFormView da rotina
/*/
Static Function ViewDef()
    Local oModel
    Local oView
    Local oStruF7O

    oModel := FwLoadModel('FING010')
    oStruF7O := FwFormStruct(2, 'F7O')
    oStruF7O:RemoveField("F7O_FILIAL")

    oView := FwFormView():New()

    oView:SetModel(oModel)

    oView:AddField('VIEW_F7O_MASTER', oStruF7O, 'F7O_MASTER')

    oView:CreateHorizontalBox('TELA_FULL', 100)
    
    oView:SetOwnerView('VIEW_F7O_MASTER', 'TELA_FULL')
Return oView

/*/{Protheus.doc} RetTableDM

    Retorna a lista de tabelas conforme a origem selecionada.

    @type  Function
    @author Alecsandre Aparecido Fabiano Santana Ferreira
    @since 03/03/2025
    @version 1.0

    @return Character, Lista de tabelas para o combo
/*/
Function RetTableDM() 
    Local cTabelas as character

    Do Case
        Case Empty(__cOrigem)
            cTabelas := "SA6=Bancos;FK5=Movimento Bancário;FK8=Dados contábeis;SE1=Titulos a Receber;SE2=Titulos a Pagar;SA1=Clientes;SA2=Fornecedores;SED=Naturezas;SEV=Múltiplas Naturezas por Título;SEZ=Distrib de Naturezas em CC"
        Case alltrim(__cOrigem) == "1"
            cTabelas := "SA2=Fornecedores;SE2=Titulos a Pagar;SED=Naturezas;SEV=Múltiplas Naturezas por Título;SEZ=Distrib de Naturezas em CC"
        Case alltrim(__cOrigem) == "2"
            cTabelas := "SA1=Clientes;SE1=Titulos a Receber;SED=Naturezas;SEV=Múltiplas Naturezas por Título;SEZ=Distrib de Naturezas em CC"
        Case alltrim(__cOrigem) == "3"
            cTabelas := "SA2=Fornecedores;SE2=Titulos a Pagar;FK5=Movimento Bancário;SED=Naturezas;SEV=Múltiplas Naturezas por Título;SEZ=Distrib de Naturezas em CC"
        Case alltrim(__cOrigem) == "4"
            cTabelas := "SA1=Clientes;SE1=Titulos a Receber;FK5=Movimento Bancário;SED=Naturezas;SEV=Múltiplas Naturezas por Título;SEZ=Distrib de Naturezas em CC"
        Case alltrim(__cOrigem) == "5"
            cTabelas := "SA6=Bancos;FK5=Movimento Bancário;FK8=Dados contábeis"
    EndCase
Return cTabelas

/*/{Protheus.doc} TriggTblDM

    Atualiza e retorna a lista de tabelas de acordo com a origem.

    @type  Function
    @author Alecsandre Aparecido Fabiano Santana Ferreira
    @since 03/03/2025
    @version 1.0

    @param cOrigem, Character, Origem/DM selecionada
    @return Character, Lista de tabelas para o combo
/*/
Function TriggTblDM(cOrigem as character)
    Local cTabelas As character
    Local aTabelas As Array
    Local oModel := FwModelActive()
    Local oView

    if cOrigem <> Nil
        cOrigem := Alltrim(cOrigem)

        __cOrigem := cOrigem

        if oView == Nil
            oView := FwViewActive()
        Endif

        cTabelas := RetTableDM()
        aTabelas := StrToArray(cTabelas, ";")   

        if oView <> Nil .And. cOrigem <> ""
            oView:SetFieldProperty('VIEW_F7O_MASTER', 'F7O_TABELA', "COMBOVALUES", {aTabelas})
            if __cTbl $ cTabelas .and. !empty(alltrim(__cTbl))
                oModel:GetModel("F7O_MASTER"):SetValue("F7O_TABELA", __cTbl)
            Endif
        EndIf
    Else
        cTabelas := RetTableDM() 
    Endif
Return cTabelas

/*/{Protheus.doc} CpoExiTbl

    Valida se a coluna existe na tabela e se esta disponivel para uso.

    @type  Function
    @author Alecsandre Aparecido Fabiano Santana Ferreira
    @since 03/03/2025
    @version 1.0

    @param cTabela, Character, Tabela informada
    @param cColuna, Character, Coluna informada
    @param cOrigem, Character, Origem/DM para validacao
    @return Logical, .T. quando a coluna e valida para uso
/*/
Function CpoExiTbl(cTabela as character, cColuna as character, cOrigem as Character)
    Local lRet as Logical
    Local lInUse As Logical
    Local lIsUpdate As Logical
    Local lColExist As Logical
    Local cColTrim As Character
    Local aTabFlex As Array
    Local nCntFor As Numeric
    Local nLenArr As Numeric
    Local oModel := FwModelActive()

    Default cOrigem := oModel:GetModel("F7O_MASTER"):GetValue("F7O_ORIGEM")
    
    cTabela := left(alltrim(cTabela), 3)
    cColTrim := alltrim(cColuna)

    lRet := .F.
    lColExist := .F.
    lInUse := .F.
    lIsUpdate := oModel:GetOperation() == MODEL_OPERATION_UPDATE

    aTabFlex := FWSX3Util():GetAllFields(cTabela)
    nLenArr := len(aTabFlex)

    if nLenArr > 0 .And. !Empty(cColTrim)
        for nCntFor := 1 to nLenArr
            lColExist := cColTrim == Alltrim(aTabFlex[nCntFor])
            if lColExist
                lRet := .T.
                exit
            Endif
        next nCntFor
    Endif 

    if lRet .And. !lIsUpdate
        DBSelectArea("F7O")
        DBSetOrder(1)
        lInUse := F7O->(DBSeek(xFilial("F7O")+cOrigem+cTabela+cColuna))
        if !lInUse
            lRet := .T.
        Else
            lRet := .F.
            Help(" ", 1, "COLEMUSO",, STR0001, 1, 0, , , , , , {STR0015 + ' ' + cTabela}) // "Campo já está em uso na tabela e processo selecionado." //Deve-se utilizar outro campo disponível na tabela
        Endif
    Endif

    if !lRet .and. !lColExist
        Help(" ", 1, "COLNAOEXISTE",, STR0010, 1, 0, , , , , , {STR0016 +' ' + cTabela}) // "Campo não existe no dicionário." //"Deve-se utilizar outro campo existente na tabela"
    Endif
Return lRet

/*/{Protheus.doc} VldFlexF

    Valida o numero do FlexField conforme origem e tamanho da coluna.

    @type  Function
    @author Alecsandre Aparecido Fabiano Santana Ferreira
    @since 03/03/2025
    @version 1.0

    @param cNro, Character, Numero do FlexField
    @param cDM, Character, Origem/DM selecionada
    @param cColuna, Character, Coluna selecionada
    @return Logical, .T. quando o FlexField e valido
/*/
Function VldFlexF(cNro as character)
    Local aLenMenor As Array
    Local aLenMaior As Array
    Local aLenMB As Array
    Local aColMenor As Array
    Local aColMaior As Array
    Local cDM As Character
    Local cColuna As Character
    Local lRet As Logical
    Local lInUseByF7 As Logical
    Local lIsUpdate As Logical
    Local oModel As Object

    oModel      := FwModelActive()
    cDM         := oModel:GetModel("F7O_MASTER"):GetValue("F7O_ORIGEM")
    cColuna     := oModel:GetModel("F7O_MASTER"):GetValue("F7O_COLUNA")
    cNro        := PadL(Alltrim(cNro), GetSX3Cache("F7O_FLEX", "X3_TAMANHO"), '0')
    lRet        := .F.
    lInUseByF7  := .F.
    lIsUpdate   := oModel:GetOperation() == MODEL_OPERATION_UPDATE
    aLenMenor   := {1, 10}
    aLenMaior   := {11, 15}
    aLenMB      := {1, 5}
    aColMenor   := {1, 50}
    aColMaior   := {31, 100}

    if cDM == '5' // Se for MB
        if Val(cNro) >= aLenMB[1] .And. val(cNro) <= aLenMB[2]
            lRet := .T.
            If GetSX3Cache(cColuna, "X3_TAMANHO") > aColMenor[2]
                lRet := .F.                                
                Help(" ", 1, "FLEXFINVALID",, STR0003, 1, 0, , , , , , {STR0017}) // "Campo indisponível para flexibilizar: Tamanho do campo maior que 50." //"Tamanho do campo deve ser menor que 50."
            Else
                lInUseByF7 := F7OFlexInUse(cDM, cNro, cColuna, lIsUpdate)
                if lInUseByF7
                    lRet := .F.
                    Help(" ", 1, "FLEXFIELDEXIST",, STR0004, 1, 0, , , , , , {STR0018}) // "Este número de campo flexivel já está configurado para este processo." //"Deve-se utilizar outro número disponível"
                Endif
            Endif
        Else
            lRet := .F.
            Help(" ", 1, "FLEXFINVALID",, STR0005, 1, 0, , , , , , {STR0019}) // "Campo flexível inválido. Digite de 01 a 05." //"O valor deve ser entre 01 a 05."
        Endif
    Else
        if GetSX3Cache(cColuna, "X3_TAMANHO") <= aColMenor[2]
            if Val(cNro) >= aLenMenor[1] .And. val(cNro) <= aLenMenor[2]
                lRet := .T.
                lInUseByF7 := F7OFlexInUse(cDM, cNro, cColuna, lIsUpdate)
                if lInUseByF7
                    lRet := .F.
                    Help(" ", 1, "FLEXFIELDEXIST",, STR0004, 1, 0, , , , , , {STR0018}) // "Este número de campo flexivel já está configurado para este processo." //"Deve-se utilizar outro número disponível"
                Endif
            Else
                lRet := .F.
                Help(" ",1,"FLEXFINVALID",, STR0006, 1, 0, , , , , , {STR0020}) // "Este campo flexível está disponível de 01 a 10 de acordo com o campo selecionado." //"O valor deve ser entre 01 a 10."
            Endif
        Elseif GetSX3Cache(cColuna, "X3_TAMANHO") >= aColMaior[1] .And. GetSX3Cache(cColuna, "X3_TAMANHO") <= aColMaior[2]
            if Val(cNro) >= aLenMaior[1] .And. val(cNro) <= aLenMaior[2]
                lRet := .T.
                lInUseByF7 := F7OFlexInUse(cDM, cNro, cColuna, lIsUpdate)
                if lInUseByF7
                    lRet := .F.
                    Help(" ", 1, "FLEXFIELDEXIST",, STR0004, 1, 0, , , , , , {STR0018}) // "Este número de campo flexivel já está configurado para este processo." //"Deve-se utilizar outro número disponível"
                Endif
            Else
                lRet := .F.                                
                Help(" ", 1, "FLEXFINVALID",, STR0007, 1, 0, , , , , , {STR0021}) // "Este campo flexivel está disponível de 11 a 15 de acordo com o campo selecionado." //"O valor deve ser entre 11 a 15."
            Endif
        Else
            lRet := .F.            
            Help(" ", 1, "FLEXFINVALID",, STR0008, 1, 0, , , , , , {STR0022}) // "Campo flexível inválido. O tamanho do campo deve ser menor ou igual a 100." //"O tamanho do campo não pode ser maior que 100"
        Endif
    Endif

    if lRet
        oModel:GetModel("F7O_MASTER"):SetValue("F7O_FLEX", cNro)
    Endif
Return lRet

/*/{Protheus.doc} F7OFlexInUse
    Verifica se o Flex esta em uso por processo/tabela.

    @type  Function
    @author Squad Financeiro
    @since 06/2026
    @version 1.2

    @param cDM, Character, Origem/DM
    @param cNro, Character, Numero do FlexField em validacao
    @param cColuna, Character, Coluna em validacao
    @param lIsUpdate, Logical, Operacao de alteracao (.T.) ou inclusao (.F.)

    @return Logical, .T. quando o numero de flex ja esta em uso por outra coluna
/*/
Static Function F7OFlexInUse(cDM as Character, cNro as Character, cColuna as Character, lIsUpdate as Logical)
    Local lRet As Logical
    Local cSeek As Character
    Local aAreaF7O As Array
    Local nRecOrig As Numeric

    Default cDM := ""
    Default cNro := ""
    Default cColuna := ""
    Default lIsUpdate := .F.

    aAreaF7O := F7O->(GetArea())
    cSeek := xFilial("F7O") + cDM
    lRet  := .F.

    DBSelectArea("F7O")
    F7O->(DbSetOrder(1))

    If lIsUpdate
        nRecOrig := F7O->(Recno())
    EndIf

    If F7O->(DbSeek(cSeek))
        While !F7O->(Eof()) .And. (F7O->F7O_FILIAL + F7O->F7O_ORIGEM) == cSeek
            If lIsUpdate
                If F7O->(Recno()) != nRecOrig .And. (F7O->F7O_FLEX == cNro .Or. F7O->F7O_COLUNA == cColuna)
                    lRet := .T.
                    exit
                EndIf
            ElseIf F7O->F7O_FLEX == cNro
                lRet := .T.
                exit
            EndIf
            F7O->(DbSkip())
        Enddo
    EndIf

    RestArea(aAreaF7O)

Return lRet

/*/{Protheus.doc} VldOrigF

    Valida o preenchimento e a edicao do campo de origem.

    @type  Function
    @author Alecsandre Aparecido Fabiano Santana Ferreira
    @since 03/03/2025
    @version 1.0

    @param cDM, Character, Origem/DM selecionada
    @param lPos, Logical, Indica se a validacao ocorre em pos-validacao
    @return Logical, .T. quando a origem e valida
/*/
Function VldOrigF(cDM as character, lPos As Logical)
    Local lRet As Logical
    Local oModel := FwModelActive()
    Default lPos := .F.
    Default cDM = oModel:GetModel("F7O_MASTER"):GetValue("F7O_ORIGEM")
    
    lRet := .F.

    lRet := Alltrim(cDM) <> ''
    if lRet
        if !lPos
            TriggTblDM(cDM)
        Endif
    Endif
Return lRet

/*/{Protheus.doc} VldTabF

    Valida o preenchimento da tabela informada no cadastro.

    @type  Function
    @author Alecsandre Aparecido Fabiano Santana Ferreira
    @since 03/03/2025
    @version 1.0

    @return Logical, .T. quando a tabela e valida
/*/
Function VldTabF()
    Local oModel
    Local oView
    Local lRet As Logical
    Local cTbl
    Local cDm As Character

    oModel := FwModelActive()
    oView := FwViewActive()
    lRet := .F.

    cDm := Alltrim(oModel:GetModel("F7O_MASTER"):GetValue("F7O_ORIGEM"))

    lRet := cDm <> ""

    If lRet
        cTbl := Alltrim(Replace(oModel:GetModel("F7O_MASTER"):GetValue("F7O_TABELA"), '=', ''))
        lRet := cTbl == '' .OR. cTbl <> Nil
        if lRet
            lRet := FwAliasInDic(cTbl)
        Endif
    Endif

Return lRet

/*/{Protheus.doc} PosVldFlex

    Executa as validacoes finais do modelo antes da gravacao.

    @type  Function
    @author Alecsandre Aparecido Fabiano Santana Ferreira
    @since 03/03/2025
    @version 1.0

    @param oModel, Object, Modelo ativo para validacao
    @return Logical, .T. quando o modelo esta valido
/*/
Static Function PosVldFlex(oModel as Object)
    Local lRet As Logical
    Default oModel := FwModelActive()

    lRet := .F.

    if oModel:GetOperation() <> MODEL_OPERATION_DELETE
        lRet := CpoExiTbl(oModel:GetModel("F7O_MASTER"):GetValue("F7O_TABELA"), oModel:GetModel("F7O_MASTER"):GetValue("F7O_COLUNA"))
        if lRet
            lRet := VldOrigF(oModel:GetModel("F7O_MASTER"):GetValue("F7O_ORIGEM"), .T.)
        Endif
        if lRet
            lRet := VldFlexF(oModel:GetModel("F7O_MASTER"):GetValue("F7O_FLEX"))
        Endif
    Else
        lRet := .T.
    Endif

    __cOrigem := ""
Return lRet 

/*/{Protheus.doc} AtuOriF

    Atualiza os valores das statics de origem e tabela selecionadas.

    @type  Function
    @author Alecsandre Aparecido Fabiano Santana Ferreira
    @since 03/03/2025
    @version 1.0

    @return Logical, .T. quando os valores sao atualizados
/*/
Function AtuOriF()
    Local lRet As Logical
    Local cTbl As Character
    Local oModel := FwModelActive()

    lRet := .F.

    cTbl := oModel:GetModel("F7O_MASTER"):GetValue("F7O_TABELA")
    __cOrigem := oModel:GetModel("F7O_MASTER"):GetValue("F7O_ORIGEM")
    if !(cTbl $ 'SA1|SA2|SA6') .and. cTbl <> __cTbl
        __cTbl := cTbl
    Endif
    TriggTblDM(__cOrigem)

    lRet := .T.
Return lRet 

/*/{Protheus.doc} F7OCommit
    Classe responsavel por orquestrar os eventos do modelo de dados da rotina
    @author Squad Financeiro
    @since 07/2026
    @version 1.0
/*/
Class F7OCommit from FWModelEvent
    Public Method new()
    Public Method AfterTTS(oModel as object)
EndClass

/*/{Protheus.doc} new
    Metodo construtor da classe
    @author Squad Financeiro
    @since 07/2026
    @version 1.0
/*/
Method new() Class F7OCommit
Return 

/*/{Protheus.doc} AfterTTS
    Método que é chamado pelo MVC quando ocorrer as ações do  após a transação.

    @author Squad Financeiro
    @since 07/2026
    @version 1.0
    @param oModel, Objeto, Modelo de dados da rotina
/*/
Method AfterTTS(oModel as object) Class F7OCommit

    FwAlertInfo(STR0023, STR0024)

Return
