#include 'Mdta090b.ch'
#include 'protheus.ch'
#include 'fwmvcdef.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} Mdta090b
Cadastro da taxa metabolica relacionada a tarefa

@author Eloisa Anibaletto
@since 08/04/2026

/*/
//---------------------------------------------------------------------
Function Mdta090b()

    Local oBrowse := Nil

    If AMiIn( 35 ) // Somente autorizado para SIGAMDT

        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias( 'TN5' )
        oBrowse:SetMenuDef( 'Mdta090b' )
        oBrowse:SetDescription( STR0001 ) // "Tarefa"
        oBrowse:Activate()

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu

@author Eloisa Anibaletto
@since 08/04/2026

@return aRotina, Array, menu da rotina
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

    aAdd( aRotina, { STR0002, 'ViewDef.Mdta090b', 0, 2, 0 } ) // "Visualizar"
    aAdd( aRotina, { STR0001, 'ViewDef.Mdta090b', 0, 4, 0 } ) // "Tarefa"

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Modelo

@author Eloisa Anibaletto
@since 08/04/2026

@return oModel, Objeto, modelo em MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStructTN5 := FWFormStruct( 1, 'TN5' )
    Local oStructTLU := FWFormStruct( 1, 'TLU' )
	Local oModel     := MPFormModel():New( 'Mdta090b', /*bPre*/, { | oModel | fMPosValid( oModel ) }/*bPost*/, /*bCommit*/, /*bCancel*/ )

    // Adiciona um componente de formulário e os componentes da aba inferior
    oModel:AddFields( 'TN5MASTER', Nil, oStructTN5 )
    oModel:AddGrid( 'TLUDETAIL', 'TN5MASTER', oStructTLU )

    // Descrições
    oModel:GetModel( 'TN5MASTER' ):SetDescription( STR0001 ) // "Tarefa"
    oModel:GetModel( 'TLUDETAIL' ):SetDescription( STR0003 ) // "Taxa Metabólica"

    // Validações
    oModel:GetModel( 'TLUDETAIL' ):SetDelAllLine( .T. )
    oModel:GetModel( 'TLUDETAIL' ):SetMaxLine( 1 ) // Apenas uma linha na grid
	oModel:GetModel( 'TN5MASTER' ):SetOnlyView( .T. ) // Trava campos do folder da TN5

    // Relacionamento entre os componentes do modelo
    oModel:SetRelation( 'TLUDETAIL', { { 'TLU_FILIAL', 'FwxFilial( "TLU" )' }, { 'TLU_CODTAR', 'TN5_CODTAR' } }, ( 'TLU' )->( IndexKey( 1 ) ) )

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da view

@author Eloisa Anibaletto
@since 08/04/2026

@return oView, Objeto, view em MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

    Local oModel        := FWLoadModel( 'Mdta090b' )
    Local oStructTN5    := FWFormStruct( 2, 'TN5' )
    Local oStructTLU    := FWFormStruct( 2, 'TLU' )
    Local oView         := FWFormView():New()

    oView:SetModel( oModel )

    // Adiciona na View controle do tipo formulário e grid
    oView:AddField( 'VIEW_TN5', oStructTN5, 'TN5MASTER' )
    oView:AddGrid( 'VIEW_TLU', oStructTLU, 'TLUDETAIL' )

    // Cria box horizontal para receber os elementos da View
    oView:CreateHorizontalBox( 'SUPERIOR', 40 )
    oView:CreateHorizontalBox( 'INFERIOR', 60 )

    // Relaciona o ID da View com o box
    oView:SetOwnerView( 'VIEW_TN5', 'SUPERIOR' )
    oView:SetOwnerView( 'VIEW_TLU', 'INFERIOR' )
    oView:SetCloseOnOk( { || .T. } ) // Remove botão salvar e criar novo

    // Descrições
    oView:EnableTitleView( "VIEW_TN5", STR0001 ) // Descrição do browse "Tarefa"
    oView:EnableTitleView( "VIEW_TLU", STR0003 ) // Descrição do browse "Taxa Metabolica"

    // Campos removidos da tela
    oStructTN5:RemoveField( "TN5_VESSYP" )
	oStructTN5:RemoveField( "TN5_ESOC"   )
    oStructTLU:RemoveField( "TLU_CODTAR" )
    
    If TLU->( FieldPos( 'TLU_NOMTAR' ) ) > 0

        oStructTLU:RemoveField( "TLU_NOMTAR" )

    EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} fMPosValid
Pós validação do modelo, neste caso é utilizado para inserir valor no campo
após todos os itens serem preenchidos.

@type   Function

@author Eduardo Mussi
@since  01/07/2026
@param  oModel, Objeto, Modelo de dados do MVC.

@return Lógico, Sempre verdadeiro.
/*/
//-------------------------------------------------------------------
Static Function fMPosValid( oModel )
    
    If TLU->( FieldPos( 'TLU_NOMTAR' ) ) > 0

        oModel:LoadValue( 'TLUDETAIL', 'TLU_NOMTAR', oModel:GetValue( 'TN5MASTER', 'TN5_NOMTAR' ) )

    EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA090GAT
Executa gatilho dos campos

@type   Function

@author Eduardo Mussi
@since  01/07/2026
@param  cDominio  , Caracter, Campo que está chamando o gatilho
@param  cContraDom, Caracter, Campo de contra dominio que receberá o valor de retorno do processo.

@return Indefinido, Retorna valor a ser carregado no campo passado pelo cDominio
/*/
//-------------------------------------------------------------------
Function MDTA090GAT( cDominio, cContraDom )

    Local xReturn
    
    If cDominio == 'TL3_CODTAR' .And. cContraDom == 'TL3_NOMTAR'

        xReturn := Posicione( 'TLU', 1, FwxFilial( 'TLU' ) + M->TL3_CODTAR, 'TLU_NOMTAR' )

    ElseIf cDominio == 'TL3_CODTAR' .And. cContraDom == 'TL3_TAXAME'

        xReturn := Posicione( 'TLU', 1, FwxFilial( 'TLU' ) + M->TL3_CODTAR, 'TLU_TAXAME' )
    
    EndIf

Return xReturn
