#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "LOJA6020.CH"

//------------------------------------------------------------------------
/*/{Protheus.doc} LOJA6020
Cadastro Filial x Consulta Estoque.
Essa rotina tem por objetivo cadastrar quais filiais podem ser consultado 
o estoque a partir de uma filial origem. O cadastro é composto por um 
formulário de cabeçalho onde é selecionada a filial origem e uma grid 
onde são listadas as filiais que podem ser consultadas a partir da filial 
origem.

@type  Function
@author Alberto Deviciente
@since 04/06/2026
@version 12
/*/
//------------------------------------------------------------------------
Function LOJA6020()
    // A função principal apenas dispara o browse
    // A configuração fica na BrowseDef (Static Function)
    Local oBrowse As Object

    oBrowse := FWLoadBrw("LOJA6020")
    oBrowse:Activate()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Definição do browse da rotina

@type  Static Function
@author Alberto Deviciente
@since 04/06/2026
@version 12
@return oBrowse, object, objeto do browse
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
    Local oBrowse As Object

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("MA1")
    oBrowse:SetDescription(STR0001) //"Filial x Consulta Estoque"

Return oBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu da rotina

@type  Static Function
@author Alberto Deviciente
@since 04/06/2026
@version 12
@return aRotina, array, opcoes do menu
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina As Array
    aRotina := {}

    ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.LOJA6020" OPERATION 2 ACCESS 0 //"Visualizar"
    ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.LOJA6020" OPERATION 3 ACCESS 0 //"Incluir"
    ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.LOJA6020" OPERATION 4 ACCESS 0 //"Alterar"
    ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.LOJA6020" OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de dados

@type  Static Function
@author Alberto Deviciente
@since 04/06/2026
@version 12
@return oModel, object, modelo de dados
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
    Local oModel    As Object
    Local oStruMA1  As Object
    Local oStruMA2  As Object

    oStruMA1  := FWFormStruct(1, "MA1")
    oStruMA2  := FWFormStruct(1, "MA2")

    // Cria o modelo de dados
    oModel := MPFormModel():New("LOJA6020", /*bPreVld*/, /*bPosVld*/ { |oModel| Lj6020VlPs( oModel ) }, /*bCommit*/, /*bCancel*/)

    // Adiciona o formulário de cabeçalho (MA1)
    oModel:AddFields("MA1MASTER", "", oStruMA1)

    // Adiciona a grid de itens (MA2)
    oModel:AddGrid("MA2DETAIL", "MA1MASTER", oStruMA2)

    // Define o relacionamento MA1 -> MA2
    oModel:SetRelation("MA2DETAIL", { {"MA2_FILIAL", "xFilial('MA2')"}, {"MA2_FILPAI", "MA1_FILPAI"} }, "MA2_FILIAL+MA2_FILPAI")

    // Impede inclusao de linhas com MA2_FILTRA duplicado na grid
    oModel:GetModel("MA2DETAIL"):SetUniqueLine({"MA2_FILTRA"})

    // Descrições do modelo
    oModel:SetDescription(STR0001) //"Filial x Consulta Estoque"
    oModel:GetModel("MA1MASTER"):SetDescription(STR0007) //"Filial Origem"
    oModel:GetModel("MA2DETAIL"):SetDescription(STR0008) //"Filiais que podem ter o estoque consultado a partir da Filial Origem"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface

@type  Static Function
@author Alberto Deviciente
@since 04/06/2026
@version 12
@return oView, object, objeto da view
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
    Local oModel   As Object
    Local oStruMA1 As Object
    Local oStruMA2 As Object
    Local oView    As Object

    oModel   := FWLoadModel("LOJA6020")
    oStruMA1 := FWFormStruct(2, "MA1")
    oStruMA2 := FWFormStruct(2, "MA2")
    oView    := FWFormView():New()

    oView:SetDescription(STR0001) //"Filial x Consulta Estoque"

    oView:SetModel(oModel)

    // Adiciona o formulário de cabeçalho (MA1)
    oView:AddField("VIEW_MA1", oStruMA1, "MA1MASTER")

    // Adiciona a grid de itens (MA2)
    oView:AddGrid("VIEW_MA2", oStruMA2, "MA2DETAIL")

    // Define os boxes de layout
    oView:CreateHorizontalBox("SUPERIOR", 20)
    oView:CreateHorizontalBox("INFERIOR", 80)

    // Associa os componentes aos boxes
    oView:SetOwnerView("VIEW_MA1", "SUPERIOR")
    oView:SetOwnerView("VIEW_MA2", "INFERIOR")

    // Exibe os titulos dos componentes
    oView:EnableTitleView("VIEW_MA1")
    oView:EnableTitleView("VIEW_MA2")

Return oView

//-------------------------------------------------------------------------------
/*/{Protheus.doc} Lj6020VlPs
Bloco de Validacao do cadastro de Filial x Consulta Estoque

@type  Static Function
@author Alberto Deviciente
@since 04/06/2026
@version 12
@param  oModel, Object, Objeto de Model do cadastro de Filial x Consulta Estoque
@return lRet, Logical, Resultado da validacao do cadastro de Filial x Consulta Estoque
/*/
//-------------------------------------------------------------------------------
Static Function Lj6020VlPs( oModel )
    Local lRet 		 As Logical
    Local nOperation As Numeric
    Local cFilOrigem As Character
    Local oGrid      As Object
    Local nLine      As Numeric
    Local nI         As Numeric

    nOperation  := oModel:GetOperation()
    lRet        := .T.

    If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE

        cFilOrigem  := oModel:GetValue("MA1MASTER", "MA1_FILPAI")
        
        If !Empty(cFilOrigem)
            oGrid   := oModel:GetModel("MA2DETAIL")
            If oGrid:GetQtdLine() > 0 
                nLine   := oGrid:GetLine() //Linha Atual do Grid
                For nI:= 1 to oGrid:GetQtdLine()
                    oGrid:GoLine(nI)
                    If !oGrid:IsDeleted()
                        If cFilOrigem == oGrid:GetValue("MA2_FILTRA")
                            Help(" ",1,"HELP" ,NIL, STR0009, 1, 0 ) //"Filial informada no grid de itens não pode ser igual a filial origem"
                            lRet := .F.
                            Exit
                        EndIf
                    EndIf
                Next nI
                oGrid:GoLine(nLine)
            EndIf
        EndIf
        
    EndIf

Return lRet
