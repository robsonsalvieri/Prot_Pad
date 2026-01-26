#Include "protheus.ch"
#Include "topconn.ch"
#include "fwmvcdef.ch"
#Include "fileio.ch"
#Include "FING010.ch"

/*
    Fonte: FING010
    Descricao: Cadastro de Flex Fields
    Autor: Alecsandre Aparecido Fabiano Santana Ferreira
    Data: 03/03/2025
*/

Static __cOrigem := ""
Static __cTbl := ""

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

/*
    Funcao: ModelDef
    Descricao: Modelo de Dados FlexFields
    Autor: Alecsandre Aparecido Fabiano Santana Ferreira
    Data: 03/03/2025
*/
Static Function ModelDef()
    Local oModel
    Local oStruF7O

    oStruF7O := FwFormStruct(1, 'F7O')

    oModel := MPFormModel():New('FING010',, {|oModel|PosVldFlex(oModel)})

    oModel:AddFields('F7O_MASTER',, oStruF7O)
    oModel:SetDescription(STR0014)
    oModel:GetModel('F7O_MASTER'):SetDescription('FlexFields')


    oModel:SetPrimaryKey({"F7O_FILIAL", "F7O_ORIGEM", "F7O_TABELA", "F7O_COLUNA"})
Return oModel


/*
    Funcao: MenuDef
    Descricao: Menudef de FlexFields
    Autor: Alecsandre Aparecido Fabiano Santana Ferreira
    Data: 03/03/2025
*/
Static Function MenuDef()
    Local aRotina := {}
    
    aAdd(aRotina, {'Visualizar', 'VIEWDEF.FING010', 0, 2, 0, NIL})
    aAdd(aRotina, {'Incluir', 'VIEWDEF.FING010', 0, 3, 0, NIL})
    aAdd(aRotina, {'Alterar', 'VIEWDEF.FING010', 0, 4, 0, NIL})
    aAdd(aRotina, {'Excluir', 'VIEWDEF.FING010', 0, 5, 0, NIL})
Return aRotina

/*
    Funcao: ViewDef
    Descricao: ViewDef de FlexFields
    Autor: Alecsandre Aparecido Fabiano Santana Ferreira
    Data: 03/03/2025
*/
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


/*
    Funcao: RetTableDM
    Descricao: Retorna a lista de tabelas, de acordo com o DM selecionado em tela pelo usuário    
    Autor: Alecsandre Aparecido Fabiano Santana Ferreira
    Data: 03/03/2025
*/
Function RetTableDM() 
    Local cTabelas as character

    Do Case
        Case Empty(__cOrigem)
            cTabelas := "SA6=Bancos;FK5=Movimento Bancário;SE1=Titulos a Receber;SE2=Titulos a Pagar;SA1=Clientes;SA2=Fornecedores;SED=Naturezas;SEV=Múltiplas Naturezas por Título;SEZ=Distrib de Naturezas em CC"
        Case alltrim(__cOrigem) == "1"
            cTabelas := "SA2=Fornecedores;SE2=Titulos a Pagar;SED=Naturezas;SEV=Múltiplas Naturezas por Título;SEZ=Distrib de Naturezas em CC"
        Case alltrim(__cOrigem) == "2"
            cTabelas := "SA1=Clientes;SE1=Titulos a Receber;SED=Naturezas;SEV=Múltiplas Naturezas por Título;SEZ=Distrib de Naturezas em CC"
        Case alltrim(__cOrigem) == "3"
            cTabelas := "SA2=Fornecedores;SE2=Titulos a Pagar;FK5=Movimento Bancário;SED=Naturezas;SEV=Múltiplas Naturezas por Título;SEZ=Distrib de Naturezas em CC"
        Case alltrim(__cOrigem) == "4"
            cTabelas := "SA1=Clientes;SE1=Titulos a Receber;FK5=Movimento Bancário;SED=Naturezas;SEV=Múltiplas Naturezas por Título;SEZ=Distrib de Naturezas em CC"
        Case alltrim(__cOrigem) == "5"
            cTabelas := "SA6=Bancos;FK5=Movimento Bancário"
    EndCase
Return cTabelas


/*
    Funcao: TriggTblDM
    Descricao: Retorna a lista de tabelas, de acordo com o DM selecionado em tela pelo usuário
    Autor: Alecsandre Aparecido Fabiano Santana Ferreira
    Data: 03/03/2025
*/
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


/*
    Funcao: CpoExiTbl
    Descricao: Verifica se campo existe na tabela selecionada pelo usuario
    Autor: Alecsandre Aparecido Fabiano Santana Ferreira
    Data: 03/03/2025
*/
Function CpoExiTbl(cTabela as character, cColuna as character, cOrigem as Character)
    Local lRet as Logical
    Local lNotInUse As Logical
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
    lNotInUse := .T.

    aTabFlex := FWSX3Util():GetAllFields(cTabela)
    nLenArr := len(aTabFlex)

    if nLenArr > 0 .And. !Empty(cColTrim)
        for nCntFor := 1 to nLenArr
            lColExist := cColTrim == Alltrim(aTabFlex[nCntFor])
            if lColExist
                lRet := .T.
                exit
            Endif
        next
    Endif 

    if lRet
        DBSelectArea("F7O")
        DBSetOrder(1)
        lNotInUse := F7O->(DBSeek(xFilial("F7O")+cOrigem+cTabela+cColuna))
        if !lNotInUse
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


/*
    Funcao: VldFlexF
    Descricao: Valida numero FlexField
    Autor: Alecsandre Aparecido Fabiano Santana Ferreira
    Data: 03/03/2025
*/
Function VldFlexF(cNro as character, cDM as Character, cColuna as Character)
    Local lRet As Logical
    Local aLenMenor As Array
    Local aLenMaior As Array
    Local aLenMB As Array
    Local aColMenor As Array
    Local aColMaior As Array
    Local oModel := FwModelActive()
    Default cDM := oModel:GetModel("F7O_MASTER"):GetValue("F7O_ORIGEM")
    Default cColuna := oModel:GetModel("F7O_MASTER"):GetValue("F7O_COLUNA")

    oModel := FwModelActive()

    lRet := .F.

    cNro := PadL(Alltrim(cNro), GetSX3Cache("F7O_FLEX", "X3_TAMANHO"), '0')

    aLenMenor := {1, 10}
    aLenMaior := {11, 15}
    aLenMB := {1, 5}

    aColMenor := {1, 30}
    aColMaior := {31, 100}

    if cDM == '5' // Se for MB
        if Val(cNro) >= aLenMB[1] .And. val(cNro) <= aLenMB[2]
            lRet := .T.
            If GetSX3Cache(cColuna, "X3_TAMANHO") > aColMenor[2]
                lRet := .F.                                
                Help(" ", 1, "FLEXFINVALID",, STR0003, 1, 0, , , , , , {STR0017}) // "Campo indisponível para flexibilizar: Tamanho do campo maior que 30." //"Tamanho do campo deve ser menor que 30."
            Else
                if oModel:GetModel("F7O_MASTER"):GetValue("F7O_FLEX") == cNro .and. oModel:GetOperation() == MODEL_OPERATION_UPDATE
                    lRet := .T.
                Else
                    DBSelectArea("F7O")
                    F7O->(DbSetOrder(2))
                    If F7O->(DbSeek(xFilial("F7O") + cDM + cNro))// se existe na tabela  com DM e FF
                        lRet := .F.                        
                        Help(" ", 1, "FLEXFIELDEXIST",, STR0004, 1, 0, , , , , , {STR0018}) // "Este número de campo flexivel já está configurado para este processo." //"Deve-se utilizar outro número disponível"
                    Endif
                End
            Endif
        Else
            lRet := .F.            
            Help(" ", 1, "FLEXFINVALID",, STR0005, 1, 0, , , , , , {STR0019}) // "Campo flexível inválido. Digite de 01 a 05." //"O valor deve ser entre 01 a 05."
        Endif
    Else
        if GetSX3Cache(cColuna, "X3_TAMANHO") <= aColMenor[2]
            if Val(cNro) >= aLenMenor[1] .And. val(cNro) <= aLenMenor[2]
                lRet := .T.
                if oModel:GetModel("F7O_MASTER"):GetValue("F7O_FLEX") == cNro .and. oModel:GetOperation() == MODEL_OPERATION_UPDATE
                    lRet := .T.
                Else
                    DBSelectArea("F7O")
                    F7O->(DbSetOrder(2))
                    If F7O->(DbSeek(xFilial("F7O") + cDM + cNro)) // se existe na tabela  com DM e FF
                        lRet := .F.                        
                        Help(" ", 1, "FLEXFIELDEXIST",, STR0004, 1, 0, , , , , , {STR0018}) // "Este número de campo flexivel já está configurado para este processo." //"Deve-se utilizar outro número disponível"
                    Endif
                End
            Else
                lRet := .F.                
                Help(" ",1,"FLEXFINVALID",, STR0006, 1, 0, , , , , , {STR0020}) // "Este campo flexível está disponível de 01 a 10 de acordo com o campo selecionado." //"O valor deve ser entre 01 a 10."
            Endif
        Elseif GetSX3Cache(cColuna, "X3_TAMANHO") >= aColMaior[1] .And. GetSX3Cache(cColuna, "X3_TAMANHO") <= aColMaior[2]
            if Val(cNro) >= aLenMaior[1] .And. val(cNro) <= aLenMaior[2]
                lRet := .T.
                if oModel:GetModel("F7O_MASTER"):GetValue("F7O_FLEX") == cNro .and. oModel:GetOperation() == MODEL_OPERATION_UPDATE
                    lRet := .T.
                Else
                    DBSelectArea("F7O")
                    F7O->(DbSetOrder(2))
                    If F7O->(DbSeek(xFilial("F7O") + cDM + cNro)) // se existe na tabela  com DM e FF
                        lRet := .F.                        
                        Help(" ", 1, "FLEXFIELDEXIST",, STR0004, 1, 0, , , , , , {STR0018}) // "Este número de campo flexivel já está configurado para este processo." //"Deve-se utilizar outro número disponível"
                    Endif
                End
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

/*
    Funcao: VldOrigF
    Descricao: Valida edicao do campo Orig
    Autor: Alecsandre Aparecido Fabiano Santana Ferreira
    Data: 03/03/2025
*/
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

/*
    Funcao: VldTabF
    Descricao: Valida se o campo esta corretamente preenchido para edicao
    Autor: Alecsandre Aparecido Fabiano Santana Ferreira
    Data: 03/03/2025
*/
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

/*
    Funcao: PosVldFlex
    Descricao: Pos Validacao Modelo
    Autor: Alecsandre Aparecido Fabiano Santana Ferreira
    Data: 03/03/2025
*/
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

/*
    Funcao: AtuOriF
    Descricao: Atualiza statics __cOrigem e __cTbl
    Autor: Alecsandre Aparecido Fabiano Santana Ferreira
    Data: 03/03/2025
*/
Function AtuOriF()
    Local lRet As Logical
    Local cTbl As Character
    oModel := FwModelActive()

    lRet := .F.

    cTbl := oModel:GetModel("F7O_MASTER"):GetValue("F7O_TABELA")
    __cOrigem := oModel:GetModel("F7O_MASTER"):GetValue("F7O_ORIGEM")
    if !(cTbl $ 'SA1|SA2|SA6') .and. cTbl <> __cTbl
        __cTbl := cTbl
    Endif
    TriggTblDM(__cOrigem)

    lRet := .T.
Return lRet 
