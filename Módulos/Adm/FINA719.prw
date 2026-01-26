#include 'totvs.ch'
#include 'FWMVCDef.ch'
#include 'FINA719.ch'

/*/{Protheus.doc} FINA719
    Cadastro de URL de prefeituras para o Portal do Cliente

    @type function
    @version 12.1.2310
    @author Victor Azevedo
    @since 28/08/2023
/*/
Function FINA719()

    Local oBrowse As Object

    If (AliasInDic("F7H"))

        //inicialliza o Browse
        oBrowse := BrowseDef()

        //ativa o browse.
        oBrowse:Activate()
    Else
        Help("", 1, "F7H", , STR0002, 1,; //"Tabela F7H não disponível."
                    ,,,,,, {STR0003})    // "Favor atualizar o sistema para que seja criada a tabela F7H."
    EndIf

Return

/*/{Protheus.doc} BrowseDef
    Definição do Browse

    @type function
    @version 12.1.2310
    @author Victor Azevedo
    @since 28/08/2023
/*/
Static Function BrowseDef()

    Local oBrowse As Object

    oBrowse := FWMBrowse():New()

    oBrowse:SetAlias('F7H')
    oBrowse:SetDescripton(STR0001) // #"Cadastro de URL"

Return oBrowse

/*/{Protheus.doc} MenuDef
    Definição das opções do menu

    @type function
    @version 12.1.2310
    @author Victor Azevedo
    @since 28/08/2023
/*/
Static Function MenuDef()
    
    Local aRotina As Array

    aRotina := FWMVCMenu('FINA719') // Retorna as opções padrões de menu.

Return aRotina

/*/{Protheus.doc} ModelDef
    Definição do Modelo de Dados

    @type function
    @version 12.1.2310
    @author Victor Azevedo
    @since 28/08/2023
/*/
Static Function ModelDef()

    Local oStrF7H   As Object
    Local oModel    As Object

    oStrF7H   := FWFormStruct(1, 'F7H')

    // validação do modelo (TudoOK)
    bPosValid := { |oMdl| F7HTDOK(oMdl) }
    // Cria o objeto do modelo de dados.
    oModel := MPFormModel():New('FINA719', /*bPreValid*/, bPosValid, /*bCommitPos*/, /*bCancel*/)

    // Adiciona a descrição do modelo de dados.
    oModel:SetDescription(STR0001) // #"Cadastro de URL"

    // Adiciona ao modelo um componente de formulário.
    oModel:AddFields('F7HMASTER', /*cOwner*/, oStrF7H, /*bPreValid*/, /*bPosValid*/, /*bLoad*/)
    oModel:GetModel('F7HMASTER'):SetDescription(STR0001) // #"Cadastro de URL"

    // Configura chave primária.
    oModel:SetPrimaryKey({"F7H_FILIAL", "F7H_EST", "F7H_CODMUN"})

// Retorna o Modelo de dados.
Return oModel

/*/{Protheus.doc} ViewDef
    Definição da Visão de Dados

    @type function
    @version 12.1.2310
    @author Victor Azevedo
    @since 28/08/2023
/*/
Static Function ViewDef()

    Local oModel  As Object
    Local oStrF7H As Object
    Local oView   As Object

    oModel  := FWLoadModel('FINA719')
    oStrF7H := FWFormStruct(2, 'F7H')
    oView   := FWFormView():New()

    // Define qual Modelo de dados será utilizado
    oView:SetModel(oModel)

    // Define que a view será fechada após a gravação dos dados no OK.
    oView:bCloseOnOk := {|| .T.}

    // Adiciona no nosso view um controle do tipo formulário (antiga enchoice).
    oView:AddField('VIEW_F7H', oStrF7H, 'F7HMASTER')

    // Cria um "box" horizontal para receber cada elemento da view.
    oView:CreateHorizontalBox('SCREEN', 100)

    // Relaciona o identificador (ID) da view com o "box" para exibição.
    oView:SetOwnerView('VIEW_F7H', 'SCREEN')

// Retorna a View de dados.
Return oView

/*/{Protheus.doc} F7HTDOK
    Validação de TudoOK do Modelo

    @type function
    @version 12.1.2310
    @author Victor Azevedo
    @since 28/08/2023
/*/
Static Function F7HTDOK(oMdl)
    
    Local lRet      As Logical
    Local oMdlF7H   As Object
    Local nOper     As Numeric
    Local cUF       As Character
    Local cCodMun   As Character
    Local cMun      As Character
    Local aAreaCC2  As Array
    Local aAreaF7H  As Array

    lRet     := .T.
    oMdlF7H  := oMdl:GetModel("F7HMASTER")
    nOper    := oMdl:GetOperation()
    cUF      := oMdlF7H:GetValue('F7H_EST')
    cCodMun  := oMdlF7H:GetValue('F7H_CODMUN')
    aAreaCC2 := CC2->(FwGetArea())
    aAreaF7H := F7H->(FwGetArea())

    CC2->(DbSetOrder( 1 ))
    If !(CC2->(DbSeek(xFilial("CC2") + cUF + cCodmun)))
        lRet    := .F.
        Help("",1,"MUNICIPIO", ,STR0006, 1,;   //"Unidade federativa ou municipio não localizados."
                ,,,,,, {STR0007})             //"Informe uma UF e municipio valido."
    Else
        cMun := CC2->CC2_MUN
    Endif

    If (lRet .and. nOper == MODEL_OPERATION_INSERT)

        F7H->(DbSetOrder(01)) //F7H_FILIAL + F7H_EST + F7H_CODMUN
	    If (F7H->(DbSeek(FWxFilial('F7H') + cUF + cCodMun)))
            Help("", 1, "MUNICIPIO", , STR0004 + ": " + cUF + " - " + cMun, 1,;   //"Municipio já cadastrado para Unidade Federativa (UF)"
                    ,,,,,, {STR0005})       //"Informe um municipio não cadastrado ou realize a alteração do municipio já cadastrado."
            lRet := .F.
        EndIf
    EndIf

    FwRestArea(aAreaCC2)
    FwRestArea(aAreaF7H)
Return lRet
