#INCLUDE "PLSCJUSPD.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} PLSCJUSPD
Cadastro de Justificativa de Glosa Padrão para Interações
@type function
@version 12.1.2510
@author Leandro Massafera
@since 22/5/2026
/*/
Function PLSCJUSPD()

    Local oBrowse

    oBrowse := FWmBrowse():New()
    oBrowse:SetAlias( 'BEO' )
    oBrowse:SetDescription(STR0001) // 'Cadastro Justificativa Glosa Padrão'
    oBrowse:Activate()

Return( NIL ) 


/*/{Protheus.doc} ViewDef
Menudef
@type function
@version 12.1.2510
@author Leandro Massafera
@since 22/5/2026
/*/
Static Function MenuDef()

    Private aRotina := {}

    aAdd( aRotina, { 'Pesquisar' , 'PesqBrw'          , 0, 1, 0, .T. } )
    aAdd( aRotina, { 'Visualizar', 'VIEWDEF.PLSCJUSPD', 0, 2, 0, NIL } )
    aAdd( aRotina, { 'Incluir'   , 'VIEWDEF.PLSCJUSPD', 0, 3, 0, NIL } ) 
    aAdd( aRotina, { 'Alterar'   , 'VIEWDEF.PLSCJUSPD', 0, 4, 0, NIL } ) 
    aAdd( aRotina, { 'Excluir'   , 'VIEWDEF.PLSCJUSPD', 0, 5, 0, NIL } )

Return aRotina


/*/{Protheus.doc} ModelDef
Modeldef
@type function
@version 12.1.2510
@author Leandro Massafera
@since 22/5/2026
/*/
Static Function ModelDef()

    // Cria a estrutura a ser usada no Modelo de Dados
    Local oModelNOT

    // Cria o objeto do Modelo de Dados
    Local oStrBEO:= FWFormStruct(1,'BEO')

    oStrBEO:SetProperty( 'BEO_DESJUS' , MODEL_FIELD_OBRIGAT, .T.)
    oStrBEO:SetProperty( 'BEO_CODJUS' , MODEL_FIELD_OBRIGAT, .T.)

    oModelNOT := MPFormModel():New( STR0001, /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

    // Adiciona ao modelo uma estrutura de formulário de edição por campo
    oModelNOT:AddFields( 'BEOMASTER', NIL, oStrBEO )
    oModelNOT:SetPrimaryKey( { "BEO_FILIAL", "BEO_CODJUS, BEO_DESJUS" } ) 

    // Adiciona a descricao do Modelo de Dados
    oModelNOT:SetDescription( STR0001 )

    // Adiciona a descricao do Componente do Modelo de Dados
    oModelNOT:GetModel( 'BEOMASTER' ):SetDescription( STR0001 )

Return oModelNOT


/*/{Protheus.doc} ViewDef
Viewdef
@type function
@version 12.1.2510
@author Leandro Massafera
@since 22/5/2026
/*/
Static Function ViewDef()  

    // Cria a estrutura a ser usada na View
    Local oModel   := FWLoadModel( 'PLSCJUSPD' )
    Local oStruBEO := FWFormStruct(2, 'BEO')
    Local oView    := FWFormView():New()

    // Define qual o Modelo de dados será utilizado

    oView:SetModel( oModel )
    oView:AddField('BEO' , oStruBEO,'BEOMASTER' )

    oView:SetViewAction( 'BUTTONOK', { |oView| } )

    oView:CreateHorizontalBox( 'BOX1', 50)
    oView:CreateVerticalBox( 'FORMBEO', 100, 'BOX1')

    oView:SetOwnerView('BEO','FORMBEO')

Return oView
