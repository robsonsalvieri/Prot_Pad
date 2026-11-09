#Include "loca104f.ch"
#INCLUDE "TOTVS.CH"
#include "FWMVCDEF.CH"

/*/{Protheus.doc} MODELDEF
Definicão do modelo Para validar a Exclusão do Romaneio
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Modelo do romaneio
/*/
STATIC FUNCTION MODELDEF()
Local oModel := FwLoadModel("LOCA104A")
Local oStruFQX := FWFormStruct( 1, 'FQX', /*bAvalCampo*/,/*lViewUsado*/ )


// Adiciona ao modelo uma estrutura de formulário de edição por Grid
oModel:AddGrid( 'GRID', "FQWMASTER", oStruFQX, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:GetModel( 'GRID' ):SetDescription(STR0001)  //"Itens do Romaneio"
//Setando a chave primária da rotina
oModel:SetRelation( 'GRID', { { 'FQX_FILIAL', 'xFilial("FQX")' } ,{"FQX_NUM","FQW_NUM"}}, FQX->( IndexKey( 1 ) ) )
    
oModel:GetModel( 'GRID' ):SetNoInserLine(.T.)
oModel:GetModel( 'GRID' ):SetNoDeleteLine(.T.)

// Liga a validação da ativacao do Modelo de Dados
oModel:SetVldActive( { | oModel | LOCA104FAC( oModel ) })

Return oModel


/*/{Protheus.doc} ViewDef
Define a View da Demanda
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Retorna a view da demanda
/*///-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'LOCA104F' )
Local oStruFQW := FWFormStruct( 2, 'FQW', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruFQX := FWFormStruct( 2, 'FQX', /*bAvalCampo*/,/*lViewUsado*/ )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_FQW', oStruFQW, 'FQWMASTER' )
oView:AddGrid( 'VIEW_FQX', oStruFQX, 'GRID' )

oView:SetViewProperty("GRID", "GRIDSEEK",    {.T.})
oView:SetViewProperty("GRID", "GRIDFILTER", {.T.})
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'CABEC' , 50 )
oView:CreateHorizontalBox( 'ITENS' , 50 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_FQW', 'CABEC' )
oView:SetOwnerView( 'VIEW_FQX', 'ITENS' )

Return oView


/*/{Protheus.doc} LOCA104FAC
Validação para varifica se podemos realizar as operações sobre o model
@type function
@version 25.10 
@author Alexandre Circenis
@since 5/6/2025
@param oModel, object, Model do ITem do Romaneio
@return variant, .T. se a operação puder ser realizada
/*/
Function LOCA104FAC( oModel )
Local lRet := .T.
Local nOpc:=oModel:GetOperation()

if nOpc <> MODEL_OPERATION_VIEW

    if nOpc == MODEL_OPERATION_DELETE
        if FQW->FQW_STATUS $ '56'
            Help(" ",1,"LOCA104F_02",, STR0002,1,0) //"Operação invalida! O Romaneio já tem documento de devolução gerado. O Romaneio não poderá ser excluido !"
    	    lRet := .F.
        endif
    endif

endif

return lRet
