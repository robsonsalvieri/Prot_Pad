#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260SE1
Browse de Historico Financeiro da Familia
@author DEV TOTVS
@since 09/12/2019
@version P12
/*/
//-------------------------------------------------------------------

Function PLSA260SE1(lAutomato)
// Declaração de Variáveis
Local oBrowse
Default lAutomato := .F.

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'BA1' )
oBrowse:SetDescription( Fundesc() )	
oBrowse:SetMenuDef( 'PLSA260SE1' )
If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu de histórico da familia
@author  DEV TOTVS
@since   09/12/2019
@version P12
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()
// Declaração de Variáveis
Local aRotina := {}

Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo de dados do histórico da familia

@author DEV TOTVS
@since 09/12/2019
@version P12
/*/
//-------------------------------------------------------------------
static function modelDef()											

	local oModel := nil	
	local oStruBA3 := FWFormStruct(1, 'BA3')
	local oStruSE1 := FWFormStruct(1, 'SE1')

	oModel := MPFormModel():New('PLSA260SE1')

	oModel:addFields('BA3MASTER', nil, oStruBA3) 
	oModel:addGrid('SE1DETAIL', 'BA3MASTER', oStruSE1)

	oModel:setRelation('SE1DETAIL', {{'E1_FILIAL', 'xFilial("SE1")'},;
									 {'E1_CODINT', 'BA3_CODINT'},;
									 {'E1_CODEMP', 'BA3_CODEMP'},;
									 {'E1_MATRIC', 'BA3_MATRIC'}},;									
									 SE1->(IndexKey(7))) 						
	
	oModel:setDescription(funDesc())
	oModel:getModel('BA3MASTER'):setDescription('Familia')
	oModel:getModel('SE1DETAIL'):setDescription('Histórico Financeiro')	

	// Não permite alteração/inclusão/exclusão no modelo
	oModel:getModel('BA3MASTER'):setOnlyQuery(.t.)
	oModel:getModel('BA3MASTER'):setOnlyView(.t.)
	oModel:getModel('SE1DETAIL'):setOnlyQuery(.t.)
	oModel:getModel('SE1DETAIL'):setOnlyView(.t.)

	oModel:setPrimaryKey({})

return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da View do histórico da familia
@author  DEV TOTVS
@since   09/12/2019
@version P12
/*/
//-------------------------------------------------------------------
static function viewDef() 

	local oStruBA3 := FWFormStruct(2, 'BA3', { |cCampo| alltrim(cCampo) $ 'BA3_CODINT|BA3_CODEMP|BA3_MATRIC|' } )
	local oStruSE1 := FWFormStruct(2, 'SE1')	
	local oModel := FWLoadModel('PLSA260SE1') 
	local oView := nil

	oView := FWFormView():new()

	oView:setModel(oModel)

	oStruSE1:removeField('E1_CODINT')
	oStruSE1:removeField('E1_CODEMP')
	oStruSE1:removeField('E1_MATRIC')

	oView:addField('VIEW_BA3', oStruBA3, 'BA3MASTER')
	oView:addGrid('VIEW_SE1', oStruSE1, 'SE1DETAIL')

	oStruBA3:setNoFolder()

	oView:addUserButton('Composição', '', {|| PLGetCompModel()}, nil, nil, nil, .t.)

	oView:createHorizontalBox('SUPERIOR', 20) 
	oView:createHorizontalBox('INFERIOR', 80) 

	oView:setOwnerView('VIEW_BA3', 'SUPERIOR')
	oView:setOwnerView('VIEW_SE1', 'INFERIOR')	
		
	oView:enableTitleView('VIEW_BA3', 'Familia')
	oView:enableTitleView('VIEW_SE1', 'Histórico Financeiro')

return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PLGetCompModel
Carrega a composição do titulo posicionado
@author  DEV TOTVS
@since   09/12/2019
@version P12
/*/
//-------------------------------------------------------------------
function PLGetCompModel()

	Local oModel := FWModelActive()
	local oModelSE1 := oModel:getModel('SE1DETAIL')
	Local cPrefix := oModelSE1:getValue('E1_PREFIXO')
	Local cNumTit := oModelSE1:getValue('E1_NUM')
	Local cParcela := oModelSE1:getValue('E1_PARCELA')
	Local cTipTit := oModelSE1:getValue('E1_TIPO')
	Local cNumCob := oModelSE1:getValue('E1_PLNUCOB')
	Local aSaveLines := FWSaveRows()

	PLSCOMPFIN(cPrefix, cNumTit, cParcela, cTipTit, cNumCob, .f., .f.)

	FWRestRows( aSaveLines )

return
