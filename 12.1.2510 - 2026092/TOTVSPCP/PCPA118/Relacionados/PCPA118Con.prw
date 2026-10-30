#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCPA118.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} ModelDef
Definição do Modelo de Consulta de Operações
@type  Static Function
@author Lucas Fagundes
@since 22/02/2022
@version P12
@return oModel - Modelo de dados definido
/*/
Static Function ModelDef()
    
    Local oModel    := Nil
    Local oStruGrid := FWFormModelStruct():New()
    Local oStruSMX  := FWFormStruct(1, "SMX")

    MontaStru(@oStruGrid, .T.)

    oModel := MPFormModel():New("PCPA118Con")
    oModel:AddFields("SMXMASTER", /*cOwner*/, oStruSMX)
    oModel:AddGrid("DETAILGRID", "SMXMASTER", oStruGrid,,,,,{|| LoadConsul()})

    oModel:GetModel("DETAILGRID"):SetDescription(STR0071) // "Grid detalhes da consulta"
    oModel:GetModel("DETAILGRID"):SetOnlyQuery(.T.)

Return oModel

/*/{Protheus.doc} ViewDef
Definição da View de Consulta de Operações
@type  Static Function
@author Lucas Fagundes
@since 22/02/2022
@version P12
@return oView - View definida
/*/
Static Function ViewDef()
    
    Local oModel    := FWLoadModel("PCPA118Con")
    Local oStruGrid := FWFormViewStruct():New()
    Local oStruSMX  := FWFormStruct(2, "SMX")
    Local oView     := Nil

    MontaStru(@oStruGrid, .F.)

    oView := FWFormView():New()

    oView:SetModel(oModel)

    oView:AddField("VIEW_SMX", oStruSMX, "SMXMASTER")
    oView:AddGrid("VIEW_GRID", oStruGrid, "DETAILGRID")

    oView:CreateHorizontalBox("SUPERIOR", 70,,.T.)
    oView:CreateHorizontalBox("INFERIOR", 100)
    oView:SetOwnerView("VIEW_SMX", "SUPERIOR")
    oView:SetOwnerView("VIEW_GRID", "INFERIOR")

Return oView

/*/{Protheus.doc} MontaStru
Função para montar a estrutura da grid.
@type  Static Function
@author Lucas Fagundes
@since 22/02/2022
@version P12
@param 01 oStruGrid, object, Objeto que será montado a estrutura
@param 02 lModel, logic, Indica se a chamada é para model ou view
@return oStruGrid, object, Objeto com a estrutura
/*/
Static Function MontaStru(oStruGrid, lModel)
    
    If lModel        
        // Estrutura do grid para o model
        oStruGrid:AddField(STR0009                                 ,;    //    [01]  C   Titulo do campo // "Roteiro"
						   STR0009                                 ,;    //    [02]  C   ToolTip do campo // "Roteiro"
						   "ROTEIRO"                               ,;    //    [03]  C   Id do Field
						   "C"                                     ,;    //    [04]  C   Tipo do campo
						   GetSx3Cache("G2_CODIGO", "X3_TAMANHO")  ,;    //    [05]  N   Tamanho do campo
						   0                                       ,;    //    [06]  N   Decimal do campo
						   NIL                                     ,;    //    [07]  B   Code-block de validação do campo
						   NIL                                     ,;    //    [08]  B   Code-block de validação When do campo
						   {}                                      ,;    //    [09]  A   Lista de valores permitido do campo // "Estrutura" "Pré-estrutura"
						   .F.                                     ,;    //    [10]  L   Indica se o campo tem preenchimento obrigatório
						   Nil                                     ,;    //    [11]  B   Code-block de inicializacao do campo
						   NIL                                     ,;    //    [12]  L   Indica se trata-se de um campo chave
						   NIL                                     ,;    //    [13]  L   Indica se o campo pode receber valor em uma operação de update.
						   .T.)                                          //    [14]  L   Indica se o campo é virtual
        oStruGrid:AddField(STR0072                                 ,;    //    [01]  C   Titulo do campo // "Produto"
						   STR0072                                 ,;    //    [02]  C   ToolTip do campo // "Produto"
						   "PRODUTO"                               ,;    //    [03]  C   Id do Field
						   "C"                                     ,;    //    [04]  C   Tipo do campo
						   GetSx3Cache("B1_COD", "X3_TAMANHO")     ,;    //    [05]  N   Tamanho do campo
						   0                                       ,;    //    [06]  N   Decimal do campo
						   NIL                                     ,;    //    [07]  B   Code-block de validação do campo
						   NIL                                     ,;    //    [08]  B   Code-block de validação When do campo
						   {}                                      ,;    //    [09]  A   Lista de valores permitido do campo // "Estrutura" "Pré-estrutura"
						   .F.                                     ,;    //    [10]  L   Indica se o campo tem preenchimento obrigatório
						   Nil                                     ,;    //    [11]  B   Code-block de inicializacao do campo
						   NIL                                     ,;    //    [12]  L   Indica se trata-se de um campo chave
						   NIL                                     ,;    //    [13]  L   Indica se o campo pode receber valor em uma operação de update.
						   .T.)                                          //    [14]  L   Indica se o campo é virtual
        oStruGrid:AddField(STR0051                                 ,;    //    [01]  C   Titulo do campo // "Descrição"
						   STR0052                                 ,;    //    [02]  C   ToolTip do campo // "Descrição do Produto"
						   "DESCRICAO"                             ,;    //    [03]  C   Id do Field
						   "C"                                     ,;    //    [04]  C   Tipo do campo
						   GetSx3Cache("B1_DESC", "X3_TAMANHO")    ,;    //    [05]  N   Tamanho do campo
						   0                                       ,;    //    [06]  N   Decimal do campo
						   NIL                                     ,;    //    [07]  B   Code-block de validação do campo
						   NIL                                     ,;    //    [08]  B   Code-block de validação When do campo
						   {}                                      ,;    //    [09]  A   Lista de valores permitido do campo // "Estrutura" "Pré-estrutura"
						   .F.                                     ,;    //    [10]  L   Indica se o campo tem preenchimento obrigatório
						   Nil                                     ,;    //    [11]  B   Code-block de inicializacao do campo
						   NIL                                     ,;    //    [12]  L   Indica se trata-se de um campo chave
						   NIL                                     ,;    //    [13]  L   Indica se o campo pode receber valor em uma operação de update.
						   .T.)                                          //    [14]  L   Indica se o campo é virtual
    Else
        // Estrutura do grid para a view
        oStruGrid:AddField("ROTEIRO"           ,;    // [01]  C   Nome do Campo
						   "00"                ,;    // [02]  C   Ordem
                           STR0009             ,;    // [03]  C   Titulo do campo // "Roteiro"    
                           STR0009             ,;    // [04]  C   Descricao do campo // "Roteiro" 
                           NIL                 ,;    // [05]  A   Array com Help
                           "C"                 ,;    // [06]  C   Tipo do campo
                           Nil                 ,;    // [07]  C   Picture
                           NIL                 ,;    // [08]  B   Bloco de PictTre Var
                           NIL                 ,;    // [09]  C   Consulta F3
                           .F.                 ,;    // [10]  L   Indica se o campo é alteravel
                           NIL                 ,;    // [11]  C   Pasta do campo
                           NIL                 ,;    // [12]  C   Agrupamento do campo
                           NIL                 ,;    // [13]  A   Lista de valores permitido do campo (Combo)
                           NIL                 ,;    // [14]  N   Tamanho maximo da maior opção do combo
                           NIL                 ,;    // [15]  C   Inicializador de Browse
                           .T.                 ,;    // [16]  L   Indica se o campo é virtual
                           NIL                 ,;    // [17]  C   Picture Variavel
                           NIL)                      // [18]  L   Indica pulo de linha após o campo
        oStruGrid:AddField("PRODUTO"           ,;    // [01]  C   Nome do Campo
						   "01"                ,;    // [02]  C   Ordem
                           STR0072             ,;    // [03]  C   Titulo do campo // "Produto"    
                           STR0072             ,;    // [04]  C   Descricao do campo // "Produto" 
                           NIL                 ,;    // [05]  A   Array com Help
                           "C"                 ,;    // [06]  C   Tipo do campo
                           Nil                 ,;    // [07]  C   Picture
                           NIL                 ,;    // [08]  B   Bloco de PictTre Var
                           NIL                 ,;    // [09]  C   Consulta F3
                           .F.                 ,;    // [10]  L   Indica se o campo é alteravel
                           NIL                 ,;    // [11]  C   Pasta do campo
                           NIL                 ,;    // [12]  C   Agrupamento do campo
                           NIL                 ,;    // [13]  A   Lista de valores permitido do campo (Combo)
                           NIL                 ,;    // [14]  N   Tamanho maximo da maior opção do combo
                           NIL                 ,;    // [15]  C   Inicializador de Browse
                           .T.                 ,;    // [16]  L   Indica se o campo é virtual
                           NIL                 ,;    // [17]  C   Picture Variavel
                           NIL)                      // [18]  L   Indica pulo de linha após o campo
        oStruGrid:AddField("DESCRICAO"         ,;    // [01]  C   Nome do Campo
						   "02"                ,;    // [02]  C   Ordem
                           STR0051             ,;    // [03]  C   Titulo do campo // "Descrição"
                           STR0052             ,;    // [04]  C   Descricao do campo // "Descrição do Produto"
                           NIL                 ,;    // [05]  A   Array com Help
                           "C"                 ,;    // [06]  C   Tipo do campo
                           Nil                 ,;    // [07]  C   Picture
                           NIL                 ,;    // [08]  B   Bloco de PictTre Var
                           NIL                 ,;    // [09]  C   Consulta F3
                           .F.                 ,;    // [10]  L   Indica se o campo é alteravel
                           NIL                 ,;    // [11]  C   Pasta do campo
                           NIL                 ,;    // [12]  C   Agrupamento do campo
                           NIL                 ,;    // [13]  A   Lista de valores permitido do campo (Combo)
                           NIL                 ,;    // [14]  N   Tamanho maximo da maior opção do combo
                           NIL                 ,;    // [15]  C   Inicializador de Browse
                           .T.                 ,;    // [16]  L   Indica se o campo é virtual
                           NIL                 ,;    // [17]  C   Picture Variavel
                           NIL)                      // [18]  L   Indica pulo de linha após o campo
    EndIf

Return oStruGrid

/*/{Protheus.doc} LoadConsul
Função reponsavel por carregar a grid com os dados da consulta
@type  Static Function
@author Lucas Fagundes
@since 22/02/2022
@version P12
@return aLoad, Array, Array com os dados da consulta, que serão inseridos no modelo
/*/
Static Function LoadConsul()
   
    Local aLoad  := {}
    Local cAlias := GetNextAlias()
    Local cCod   := SMX->MX_CODIGO

    // Consulta a tabela SG2 em busca dos cadastros que utilizem a lista
    BeginSql alias cAlias
        SELECT
            DISTINCT SG2.G2_CODIGO,
            SG2.G2_PRODUTO,
            SB1.B1_DESC
        FROM
            %table:SG2% SG2
        INNER JOIN %table:SB1% SB1
            ON SG2.G2_PRODUTO = SB1.B1_COD AND
            SB1.B1_FILIAL = %xfilial:SB1% AND
            SB1.%notDel%
        WHERE
            SG2.G2_LISTA = %exp:cCod% AND
            SG2.G2_FILIAL = %xfilial:SG2% AND
            SG2.%notDel%
        ORDER BY
            SG2.G2_PRODUTO
    EndSql

    // Carrega o array com os dados que serão carregados no modelo
    While !(cAlias)->(EOF())
        aAdd(aLoad, {0, {(cAlias)->(G2_CODIGO),;
                         (cAlias)->(G2_PRODUTO),;
                         (cAlias)->(B1_DESC)}})

        (cAlias)->(DbSkip())
    End

    (cAlias)->(dbCloseArea())

Return aLoad
