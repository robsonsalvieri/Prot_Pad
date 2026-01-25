#Include "Protheus.ch"
#Include "FwMvcDef.ch"

PUBLISH MODEL REST NAME FISA308

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA308
Cadastro de Grupos de Produto - Complemento de Rastreabilidade.
Obs.: Essa rotina substiruirá o controle de Grupos de Produtos que era feito via SX5 da tabela T0 que será descontinuada.

@author pereira.weslley
@since 10/02/2023
@version P12.1.2310
/*/
//-------------------------------------------------------------------
Function FISA308()
Local oBrowse

If AliasInDic("CJP")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('CJP')
    oBrowse:SetDescription('Cadastro de Grupo de Produtos com Rastreabilidade')
    CgAut308()
    oBrowse:Activate()
Else
    Alert("Tabela CJP não encontrada, é necessária a atualização do dicionário de dados.")
EndIf

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.FISA308' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.FISA308' OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.FISA308' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.FISA308' OPERATION 5 ACCESS 0

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel := MPFormModel():New('FISA308', /*bPreValidacao*/, { |oModel| FS308POS( oModel ) }, /*bCommit*/, /*bCancel*/ ) // Cria o objeto do Modelo de Dados
Local oStruCJP := FWFormStruct( 1, 'CJP', /*bAvalCampo*/,/*lViewUsado*/ ) // Cria a estrutura a ser usada no Modelo de Dados

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CJPMASTER', /*cOwner*/, oStruCJP, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:setPrimaryKey({"CJP_FILIAL", "CJP_COD"})

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( 'Modelo de Dados de Grupos de Produto - Complemento de Rastreabilidade' )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CJPMASTER' ):SetDescription( 'Dados de Grupos de Produto - Complemento de Rastreabilidade' )

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel( 'FISA308' ) // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oStruCJP := FWFormStruct( 2, 'CJP' ) // Cria a estrutura a ser usada na View
Local oView    := FWFormView():New() // Cria o objeto de View

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CJP', oStruCJP, 'CJPMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CJP', 'TELA' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} CgAut308
Carga autmática da tabela CJP de acordo com o que está cadastrado na SX5-T0 e também na SBM.

@author pereira.weslley
@since 13/02/2023
@version P12.1.2310
/*/
//-------------------------------------------------------------------
Static function CgAut308()
    Local aSX5T0 := {}
    Local nX     := 0
    
    DbSelectArea("CJP")

    If !CJP->(DbSeek(xFilial("CJP"))) //Se não encontrar nada na CJP sigo para carga
        DbSelectArea("SBM")
        SBM->(DbSetOrder(1))

        aSX5T0 := FWGetSX5('T0')

        For nX:=1 to Len(aSX5T0)
            If Empty(aSX5T0[nX][1]) .Or. aSX5T0[nX][1] == xFilial("CJP") //Se a SX5-T0 for totalmente compartilhada ou se for da mesma filial da CJP
                If SBM->(DbSeek(xFilial("SBM")+aSX5T0[nX][3])) //Se o código do Grupo existir na SBM, segue para carga na CJP
                    RecLock("CJP", .T.)
                    CJP->CJP_FILIAL := xFilial("CJP")
                    CJP->CJP_COD    := aSX5T0[nX][3]
                    MsUnlock()
                EndIf
            EndIf
        Next
    EndIf
    
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Fs308Pos
Pos validação do modelo da CJP.

@author pereira.weslley
@since 13/02/2023
@version P12.1.2310
/*/
//-------------------------------------------------------------------
Static function Fs308Pos(oModel)
    Local lRet := .T.
    Local cCJPCod := oModel:GetValue('CJPMASTER', 'CJP_COD')
    Local nOper  := oModel:GetOperation()

    If !nOper == MODEL_OPERATION_DELETE
        DbSelectArea("CJP")
        DbSelectArea("SBM")
        CJP->(DbSetOrder(1))
        SBM->(DbSetOrder(1))

        If CJP->(DbSeek(xFilial("CJP")+cCJPCod))
            Alert("Esse código já existe cadastrado na tabela CJP - Grupos de Produto - Complemento de Rastreabilidade")
            lRet := .F.
        EndIf
    EndIf

Return lRet
